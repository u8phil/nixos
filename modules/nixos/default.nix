{ ... }:

{
  imports = [
    ./boot.nix
    ./networking.nix
    ./locale.nix
    ./desktop.nix
    ./printing.nix
    ./audio.nix
    ./virtualization.nix
    ./users.nix
    ./packages.nix
    ./nix.nix
    ./sops.nix
    ./openvpn.nix
    ./hysteria.nix
  ];
}
