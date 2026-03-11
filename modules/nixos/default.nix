{ ... }:

{
  imports = [
    ./boot.nix
    ./networking.nix
    ./bluetooth.nix
    ./locale.nix
    ./desktop.nix
    ./printing.nix
    ./audio.nix
    ./users.nix
    ./packages.nix
    ./nix.nix
    ./sops.nix
    ./openvpn.nix
    ./hysteria.nix
  ];

  # out-of-memory killer
  systemd.oomd = {
    enableRootSlice = true;
    enableUserSlices = true;
  };

  # No perl messing with my /etc
  system.etc.overlay.enable = true;

  security.rtkit.enable = true;
}
