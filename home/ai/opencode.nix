{
  config,
  cocoindexCodePackage,
  inputs,
  pkgs,
  ...
}:
let
  # Same local-proxy wrapping as claude-code: nix-daemon/ISP blocks direct
  # egress, so route opencode (bun-runtime → respects HTTP(S)_PROXY) and its
  # spawned children through the local proxy. --set-default lets a real env
  # var still override.
  proxy = "http://127.0.0.1:18081";
  ccc = cocoindexCodePackage;
  opencodeRuntimePath = pkgs.lib.makeBinPath [
    ccc
    pkgs.rtk
    pkgs.bun
    pkgs.tmux
    pkgs.libnotify
    pkgs.kdotool
    pkgs.git
    pkgs.gawk
    pkgs.coreutils
    pkgs.file
    pkgs.ripgrep
    pkgs.gdb
    pkgs.binutils
    pkgs.nodejs
    pkgs.rust-analyzer
    pkgs.nixd
  ];
  opencode = pkgs.opencode.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];
    postInstall = (old.postInstall or "") + ''
      wrapProgram $out/bin/opencode \
        --prefix PATH : ${opencodeRuntimePath} \
        --set-default HTTP_PROXY ${proxy} \
        --set-default HTTPS_PROXY ${proxy} \
        --set-default NO_PROXY localhost,127.0.0.1 \
        --set OPENCODE_DISABLE_CLAUDE_CODE_PROMPT true \
        --set-default COCOINDEX_DISABLE_USAGE_TRACKING 1
    '';
  });
  cocoindexCode = inputs.cocoindex-code;
  ohMyOpenagent = inputs.oh-my-openagent;
  serena = inputs.serena.packages.${pkgs.system}.serena;

  # Inject the GitHub token into the MCP server at runtime by reading the sops
  # secret file (config.sops.secrets.github-mcp.path). Only the file path is
  # baked into the store; the token itself stays in the 0400 sops runtime file
  # and never touches systemd environment.d. `$(cat ...)` strips any trailing
  # newline.
  githubMcpServer = pkgs.writeShellScriptBin "github-mcp-server" ''
    export GITHUB_PERSONAL_ACCESS_TOKEN="$(${pkgs.coreutils}/bin/cat ${config.sops.secrets.github-mcp.path})"
    exec ${pkgs.github-mcp-server}/bin/github-mcp-server "$@"
  '';
in
{
  home.sessionVariables.OMO_SEND_ANONYMOUS_TELEMETRY = "0";

  programs.opencode = {
    enable = true;
    package = opencode;
    context = ''
      @RTK.md

      This is a NixOS flake for the local system. Never grep, find, or search
      across /nix/store. If a needed tool is missing, use
      `nix shell nixpkgs#<package> -c <command>`.

      OpenCode owns Serena (MCP) and ccc (skill + `ccc` CLI) lifecycle. Do not
      ask the user to run serena or ccc setup commands manually; for ccc, run
      `ccc init`/`ccc index`/`ccc search` yourself per the ccc skill.

      For code search in this repo, prefer `ccc search` (semantic/conceptual)
      and Serena's symbol tools (definitions, references, call sites) over plain
      grep/glob.
    '';
    tui.theme ="one-dark";
    skills.ccc = "${cocoindexCode}/skills/ccc";
    skills.debugging = "${ohMyOpenagent}/packages/shared-skills/skills/debugging";
    skills."git-master" = "${ohMyOpenagent}/packages/shared-skills/skills/git-master";
    skills."remove-ai-slops" = "${ohMyOpenagent}/packages/shared-skills/skills/remove-ai-slops";
    skills."visual-qa" = "${ohMyOpenagent}/packages/shared-skills/skills/visual-qa";
    settings = {
      instructions = [ "AGENTS.md" ];
      plugin = [
        "@tarquinen/opencode-dcp@3.1.12"
        "@mohak34/opencode-notifier@0.2.7"
        "@ex-machina/opencode-anthropic-auth@1.8.1"
        "./plugins/guardian.ts"
      ];
      permission = {
        bash = {
          "*" = "ask";
          "rm *devenv.local.nix*" = "deny";
          "rm *.opencode/AGENTS.md*" = "deny";
          "rmdir *devenv.local.nix*" = "deny";
          "rmdir *.opencode/AGENTS.md*" = "deny";
          "rm */home/phil/work" = "deny";
          "rmdir */home/phil/work" = "deny";
        };
      };
      mcp.github = {
        enabled = true;
        type = "local";
        command = [
          "${githubMcpServer}/bin/github-mcp-server"
          "stdio"
          "--read-only"
        ];
      };
      mcp.nixos = {
        enabled = true;
        type = "local";
        command = [
          "${pkgs.mcp-nixos}/bin/mcp-nixos"
        ];
        env.MCP_NIXOS_TRANSPORT = "stdio";
      };
      mcp.serena = {
        enabled = true;
        type = "local";
        command = [
          "${serena}/bin/serena"
          "start-mcp-server"
          "--context"
          "ide"
          "--project-from-cwd"
          "--open-web-dashboard"
          "false"
        ];
      };
      # No ccc MCP server: `ccc mcp` calls require_project_root() and hard-exits
      # in an uninitialized project, so it dies at OpenCode startup. ccc is
      # instead driven through the `ccc` skill + the `ccc` CLI (on the wrapper
      # PATH above), which inits/indexes/searches lazily per project.
      mcp.websearch = {
        enabled = true;
        type = "remote";
        url = "https://mcp.exa.ai/mcp?tools=web_search_exa";
        oauth = false;
      };
      mcp."microsoft-learn" = {
        enabled = true;
        type = "remote";
        url = "https://learn.microsoft.com/api/mcp";
      };
    };
  };

  # RTK ships a native OpenCode plugin that intercepts shell tool execution via
  # tool.execute.before and rewrites commands through `rtk rewrite`.
  xdg.configFile."opencode/plugins/rtk.ts".source = "${pkgs.rtk.src}/hooks/opencode/rtk.ts";
  xdg.configFile."opencode/plugins/guardian.ts".source = ./guardian.ts;
  xdg.configFile."opencode/RTK.md".source = "${pkgs.rtk.src}/hooks/claude/rtk-awareness.md";
  xdg.configFile."opencode/dcp.jsonc".text = builtins.toJSON {
    "$schema" = "https://raw.githubusercontent.com/Opencode-DCP/opencode-dynamic-context-pruning/master/dcp.schema.json";
    compress = {
      minContextLimit = 250000;
      maxContextLimit = 325000;
    };
  } + "\n";
}
