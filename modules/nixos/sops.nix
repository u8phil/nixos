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
