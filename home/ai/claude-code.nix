{
  pkgs,
  claude-plugins,
  inputs,
  ...
}:
{
  programs.claude-code =
    let
      proxy = "http://127.0.0.1:18081";
      docsMcpVersion =
        (builtins.fromJSON (builtins.readFile (inputs."docs-mcp-server" + "/package.json"))).version;
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
      skills = inputs."docs-mcp-server" + "/skills";

      settings.effortLevel = "high";
      settings.statusLine = {
        type = "command";
        command = "bash \"${inputs.caveman}/hooks/caveman-statusline.sh\"";
      };

      mcpServers.github = {
        type = "stdio";
        command = "github-mcp-server";
        args = [
          "stdio"
          "--read-only"
        ];
      };
      mcpServers."docs-mcp" = {
        type = "stdio";
        command = "${pkgs.nodejs}/bin/npx";
        args = [
          "-y"
          "@arabold/docs-mcp-server@${docsMcpVersion}"
        ];
      };
    };
}
