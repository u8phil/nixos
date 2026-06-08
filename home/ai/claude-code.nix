# CLAUDE.md fragments + rtk hook wiring adapted from matteo-pacini's config:
# https://github.com/matteo-pacini/nixos-configs
{
  config,
  pkgs,
  lib,
  claude-plugins,
  inputs,
  ...
}:
let
  proxy = "http://127.0.0.1:18081";
  claude-code = pkgs.claude-code.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      wrapProgram $out/bin/claude \
        --prefix PATH : ${pkgs.nodejs}/bin:${pkgs.rtk}/bin:${pkgs.jq}/bin \
        --set CLAUDE_CODE_AUTO_COMPACT_WINDOW 1000000 \
        --set ENABLE_PROMPT_CACHING_1H 1 \
        --set-default HTTP_PROXY ${proxy} \
        --set-default HTTPS_PROXY ${proxy} \
        --set-default NO_PROXY localhost,127.0.0.1
    '';
  });

  # CLAUDE.md assembled from numbered fragments. `@RTK.md` reference is
  # injected after fragment 1 so Claude knows the rtk meta-commands.
  claudeMd = lib.concatStringsSep "\n" [
    (builtins.readFile ./prompts/01-role-tone.md)
    "@RTK.md\n"
    (builtins.readFile ./prompts/02-working-on-code.md)
    (builtins.readFile ./prompts/03-git.md)
    (builtins.readFile ./prompts/04-non-negotiables.md)
  ];

  # pkgs.rtk.src is the unpacked GitHub tarball; its files come without the
  # +x bit (nix store fixes mode to 0444). Re-install the hook script with
  # mode 0755 so Claude Code can exec it directly.
  rtkHook = pkgs.runCommandLocal "rtk-rewrite.sh" { } ''
    install -Dm755 ${pkgs.rtk.src}/hooks/claude/rtk-rewrite.sh $out
  '';

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
  programs.claude-code = {
    enable = true;
    package = claude-code;

    plugins = claude-plugins;
    context = claudeMd;

    settings.effortLevel = "xhigh";
    settings.statusLine = {
      type = "command";
      command = "bash \"${inputs.caveman}/hooks/caveman-statusline.sh\"";
    };
    settings.hooks.PreToolUse = [
      {
        matcher = "Bash";
        hooks = [
          {
            type = "command";
            command = "${rtkHook}";
          }
        ];
      }
    ];

    mcpServers.github = {
      type = "stdio";
      command = "${githubMcpServer}/bin/github-mcp-server";
      args = [
        "stdio"
        "--read-only"
      ];
    };
  };

  # rtk-awareness doc pulled from nixpkgs rtk's source tarball, pinned to the
  # same upstream tag as the rtk binary. Referenced from
  # CLAUDE.md as `@RTK.md`.
  home.file.".claude/RTK.md".source = "${pkgs.rtk.src}/hooks/claude/rtk-awareness.md";
}
