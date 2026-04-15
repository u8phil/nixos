{ pkgs, ... }:
{
  programs.claude-code =
    let
      proxy = "http://127.0.0.1:18081";
    in
    {
      package =
        (pkgs.extend (
          _: prev: {
            claude-code = prev.claude-code.overrideAttrs (oldAttrs: {
              postFixup = (oldAttrs.postFixup or "") + ''
                wrapProgram $out/bin/claude \
                  --set-default HTTP_PROXY ${proxy} \
                  --set-default HTTPS_PROXY ${proxy} \
                  --set-default NO_PROXY localhost,127.0.0.1
              '';
            });
          }
        )).claude-code;
      enable = true;
      mcpServers.github = {
        command = "github-mcp-server";
        args = [
          "stdio"
          "--read-only"
        ];
        env.GITHUB_PERSONAL_ACCESS_TOKEN = "{env:GITHUB_PERSONAL_ACCESS_TOKEN}";
      };
    };
}
