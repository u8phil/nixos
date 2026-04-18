{
  pkgs,
  inputs,
  ...
}:
let
  proxy = "http://127.0.0.1:18081";
in
{
  xdg.configFile = {
    "opencode/AGENTS.md".source = inputs.context-mode + "/configs/opencode/AGENTS.md";
    "opencode/plugins/context-mode.ts".text = ''
      export { ContextModePlugin } from "${inputs.context-mode}/src/opencode-plugin.ts";
    '';
  };

  programs.opencode = {
    package =
      (pkgs.extend (
        _: prev: {
          opencode = prev.opencode.overrideAttrs (oldAttrs: {
            postFixup = (oldAttrs.postFixup or "") + ''
              wrapProgram $out/bin/opencode \
                --set-default HTTP_PROXY ${proxy} \
                --set-default HTTPS_PROXY ${proxy} \
                --set-default NO_PROXY localhost,127.0.0.1 \
            '';
          });
        }
      )).opencode;
    enable = true;
    tui.theme = "one-dark";
    settings = {
      instructions = [
        "${inputs.caveman}/rules/caveman-activate.md"
      ];
      mcp.github = {
        enabled = true;
        type = "local";
        command = [
          "github-mcp-server"
          "stdio"
          "--read-only"
        ];
      };
      mcp."microsoft-learn" = {
        enabled = true;
        type = "remote";
        url = "https://learn.microsoft.com/api/mcp";
      };
      mcp."context-mode" = {
        enabled = true;
        type = "local";
        command = [
          "${pkgs.nodejs}/bin/node"
          "${inputs.context-mode}/cli.bundle.mjs"
        ];
      };
    };
  };
}
