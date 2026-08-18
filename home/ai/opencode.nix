{
  config,
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
  opencodeRuntimePath = pkgs.lib.makeBinPath [
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
        --set AI_AGENT 1 \
        --set OPENCODE_DISABLE_CLAUDE_CODE_PROMPT true \
        --set OPENCODE_DISABLE_CLAUDE_CODE_SKILLS true
    '';
  });
  ohMyOpenagent = inputs.oh-my-openagent;

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
      This is a NixOS flake for the local system. Never grep, find, or search
      across /nix/store. If a needed tool is missing, use
      `nix shell nixpkgs#<package> -c <command>`.
    '';
    tui.theme ="one-dark";
    skills.debugging = "${ohMyOpenagent}/packages/shared-skills/skills/debugging";
    skills."fusion-setup" = "${inputs.opencode-fusion}/.opencode/skills/fusion-setup";
    skills."git-master" = "${ohMyOpenagent}/packages/shared-skills/skills/git-master";
    skills."remove-ai-slops" = "${ohMyOpenagent}/packages/shared-skills/skills/remove-ai-slops";
    skills."visual-qa" = "${ohMyOpenagent}/packages/shared-skills/skills/visual-qa";
    settings = {
      instructions = [ "AGENTS.md" ];
      model = "openai/gpt-5.6-sol";
      small_model = "openai/gpt-5.6-luna";
      subagent_depth = 2;
      agent = {
        build.model = "openai/gpt-5.6-sol";
        explore.model = "openai/gpt-5.6-luna";
        sidekick.model = "openai/gpt-5.6-luna";
      };
      plugin = [
        "@mohak34/opencode-notifier@0.2.7"
        "@ex-machina/opencode-anthropic-auth@1.8.1"
        "./plugins/guardian.ts"
      ];
      provider = {
        openai = {
          models = {
            "gpt-5.6-luna".name = "GPT-5.6 Luna";
            "gpt-5.6-sol".name = "GPT-5.6 Sol";
          };
          options = {
            headerTimeout = 60000;
            timeout = 600000;
            chunkTimeout = 60000;
          };
        };
      };
      permission = {
        bash = {
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
      mcp.websearch = {
        enabled = true;
        type = "remote";
        url = "https://mcp.exa.ai/mcp?tools=web_search_exa";
        oauth = false;
      };
    };
  };

  xdg.configFile."opencode/plugins/guardian.ts".source = ./guardian.ts;
  xdg.configFile."opencode/agent/build.md".source = "${inputs.opencode-fusion}/.opencode/skills/fusion-setup/agent/build.md";
  xdg.configFile."opencode/agent/plan.md".source = "${inputs.opencode-fusion}/.opencode/skills/fusion-setup/agent/plan.md";
  xdg.configFile."opencode/agent/sidekick.md".source = "${inputs.opencode-fusion}/.opencode/skills/fusion-setup/agent/sidekick.md";
}
