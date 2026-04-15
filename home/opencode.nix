{
  pkgs,
  ...
}:
let
  proxy = "http://127.0.0.1:18081";
in
{
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
      mcp.github = {
        enabled = true;
        type = "local";
        command = [
          "github-mcp-server"
          "stdio"
          "--read-only"
        ];
        environment.GITHUB_PERSONAL_ACCESS_TOKEN = "{env:GITHUB_PERSONAL_ACCESS_TOKEN}";
      };
      mcp."microsoft-learn" = {
        enabled = true;
        type = "remote";
        url = "https://learn.microsoft.com/api/mcp";
      };
    };
  };
}
