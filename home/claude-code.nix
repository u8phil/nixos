{ pkgs, claude-plugins, ... }:
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

      plugins = claude-plugins;

      mcpServers.github = {
        type = "stdio";
        command = "github-mcp-server";
        args = [
          "stdio"
          "--read-only"
        ];
      };
      mcpServers."docs-mcp" = {
        type = "sse";
        url = "http://127.0.0.1:6820/sse";
      };
    };
}
