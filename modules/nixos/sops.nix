{ config, ... }:
{
  sops = {
    defaultSopsFile = ../../secrets/work-vpn.yaml;
    defaultSopsFormat = "yaml";

    age.sshKeyPaths = [
      "/var/lib/sops-nix/keys/sops-nix-ssh"
    ];

    secrets.server = {
      owner = "root";
      group = "root";
      mode = "0400";
    };

    secrets.github-mcp = {
      owner = "phil";
      group = "users";
      mode = "0400";
    };

    templates.github-mcp-environment = {
      owner = "phil";
      group = "users";
      mode = "0400";
      path = "/home/phil/.config/environment.d/10-github-mcp.conf";
      content = ''
        GITHUB_PERSONAL_ACCESS_TOKEN=${config.sops.placeholder.github-mcp}
      '';
    };

    templates.ssh-host-config = {
      owner = "phil";
      group = "users";
      mode = "0400";
      content = ''
        Host riga
          User root
          HostName ${config.sops.placeholder.server}
      '';
    };
  };
}
