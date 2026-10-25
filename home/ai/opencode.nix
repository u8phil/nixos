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
  gitlabMcp =
    let
      src = inputs.gitlab-mcp;
      version = (builtins.fromJSON (builtins.readFile "${src}/package.json")).version;
    in
    pkgs.buildNpmPackage {
      pname = "gitlab-mcp";
      inherit src version;
      npmDeps = pkgs.importNpmLock { npmRoot = src; };
      npmConfigHook = pkgs.importNpmLock.npmConfigHook;
      meta = {
        description = "GitLab MCP server";
        homepage = "https://github.com/zereight/gitlab-mcp";
        license = pkgs.lib.licenses.mit;
        mainProgram = "zereight-mcp-gitlab";
      };
    };
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
    pkgs.ast-grep
    pkgs.rust-analyzer
    pkgs.nixd
    gitlabMcp
  ];

  opencode = pkgs.opencode.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];
    postInstall = (old.postInstall or "") + ''
      wrapProgram $out/bin/opencode \
        --prefix PATH : ${opencodeRuntimePath} \
        --set-default HTTP_PROXY ${proxy} \
        --set-default HTTPS_PROXY ${proxy} \
        --set-default NO_PROXY localhost,127.0.0.1 \
        --run 'export NO_PROXY="$NO_PROXY,dev.corp.$(${pkgs.coreutils}/bin/cat ${config.sops.secrets."job/host".path})"' \
        --run 'export WORK_GITLAB_TOKEN="$(${pkgs.coreutils}/bin/cat ${config.sops.secrets."job/gitlab-token".path})"' \
        --run 'export TYPESAFE_API_KEY="$(${pkgs.coreutils}/bin/cat ${config.sops.secrets."typesafe-api-key".path})"' \
        --set AI_AGENT 1 \
        --set OPENCODE_DISABLE_CLAUDE_CODE_PROMPT true \
        --set OPENCODE_DISABLE_CLAUDE_CODE_SKILLS true \
        --set OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS true
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
  sops.secrets."job/host" = { };
  sops.secrets."job/gitlab-token" = { };
  sops.secrets."typesafe-api-key" = { };

  home.sessionVariables.OMO_SEND_ANONYMOUS_TELEMETRY = "0";
  home.sessionVariables.DO_NOT_TRACK = "1";

  programs.opencode = {
    enable = true;
    package = opencode;
    context = ''
      This is a NixOS flake for the local system. Never grep, find, or search
      across /nix/store. If a needed tool is missing, use
      `nix shell nixpkgs#<package> -c <command>`.

      ## Verify once, at the end, by the owner
      Several agents often work in parallel on one task. If each one validates
      the whole project, the same expensive work runs N times and goes stale
      as soon as the next edit lands. Prove a change with the smallest effort
      that actually shows it works, and do it once: the agent that owns the
      task verifies at the end, scoped to what changed. Subagents do the edit
      they were given and report what changed plus any risks. They don't add
      verification on their own initiative or repeat checks the owner will
      run. If broader verification seems needed, they say so in the report
      instead of running it.

      Minimize launching things in background. It's great to streamline commands,
      but when the blocking step of work is launched 
    '';
    tui.theme ="one-dark";
    skills.debugging = "${ohMyOpenagent}/packages/shared-skills/skills/debugging";
    skills."typesafe-ai" = "${inputs.typesafe-skills}/skills/typesafe-ai";
    skills.ast-grep = "${inputs.ast-grep-skills}/ast-grep/skills/ast-grep";
    skills.ast-grep-outline = "${inputs.ast-grep-skills}/ast-grep/skills/outline";
    mutableSettings = false;
    settings = {
      subagent_depth = 2;
      model = "openai/gpt-6.1-sol";
      small_model = "anthropic/claude-sonnet-5-5";
      default_agent = "orchestrator";
      agent = {
        build.disable = true;
        general.disable = true;
        explore.disable = true;
        plan.model = "openai/gpt-6.1-sol";
        plan.variant = "xhigh";
      };
      plugins = [
        "@mohak34/opencode-notifier@latest"
        "@ex-machina/opencode-anthropic-auth@next"
        "./plugins/guardian"
        "./plugins/ignore-root-agents"
        "oh-my-opencode-slim@latest"
      ];
      provider = {
        openai = {
          models = {
            "gpt-6-luna".name = "GPT-6 Luna";
            "gpt-6.1-sol".name = "GPT-6.1 Sol";
            "gpt-6-astra".name = "GPT-6 Astra";
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
        read = {
          "~/work/**" = "allow";
          "/tmp/**" = "allow";
        };
        edit = {
          "~/work/**" = "allow";
          "/tmp/**" = "allow";
        };
        external_directory = {
          "~/.cargo/**" = "allow";
          "/nix/store/**" = "allow";
          "~/work/**" = "allow";
          "/tmp/**" = "allow";
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

      # ignore .gitignore and let the @ binding work on git ignored files/folders.
      fileCompletion.respectGitignore = false;
    };
  };

  # V2 plugins must be directories. The host supplies `@opencode/plugin` at
  # runtime (the installed OpenCode's own version), so no package.json needed.
  xdg.configFile."opencode/plugins/guardian/index.ts".source = ./guardian.ts;
  xdg.configFile."opencode/plugins/ignore-root-agents/index.ts".source = ./ignore-root-agents.ts;
  xdg.configFile."opencode/oh-my-opencode-slim.json".source = ./oh-my-opencode-slim.json;
}
