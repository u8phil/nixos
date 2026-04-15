{
  config,
  pkgs,
  ...
}:
{
  sops.secrets.github-mcp = {};
  sops.templates.github-mcp = {
    path = "/home/phil/.config/environment.d/10-github-mcp.conf";
    content = ''
      GITHUB_PERSONAL_ACCESS_TOKEN=${config.sops.placeholder.github-mcp}
    '';
  };

  home.packages = [
    pkgs.github-mcp-server
  ];
}
