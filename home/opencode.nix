{ pkgs, ... }:
{
  programs.opencode =
    let
      proxy = "http://127.0.0.1:18081";
    in
    {
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
      settings = {
        theme = "one-dark";
        mcp.github = {
          type = "local";
          command = [
            "github-mcp-server"
            "stdio"
            "--read-only"
          ];
          environment.GITHUB_PERSONAL_ACCESS_TOKEN = "{env:GITHUB_PERSONAL_ACCESS_TOKEN}";
          enabled = true;
        };
      };
    };

}
