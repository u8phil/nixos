{ ... }:

{
  sops = {
    defaultSopsFile = ../../secrets/work-vpn.yaml;
    defaultSopsFormat = "yaml";

    age.sshKeyPaths = [
      "/var/lib/sops-nix/keys/sops-nix-ssh"
    ];
  };
}
