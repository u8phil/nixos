{ config, ... }:
{
  # never set template's path to a folder in a user's directory, when switching it creates a folder with root privileges
  # and then creates a file with the defined priveleges, so if you point to a file ~/example/foo.conf, the example
  # folder will be created with root privilges and foo.conf will be created with owner/group/mode ownage
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
