{ pkgs, ... }:

{
  imports = [
    ./boot.nix
    ./networking.nix
    ./journald.nix
    ./bluetooth.nix
    ./power.nix
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
    ./steam.nix
  ];

  # out-of-memory killer
  systemd.oomd = {
    enableRootSlice = true;
    enableUserSlices = true;
  };

  security.wrappers.sniffnet = {
    owner = "root";
    group = "root";
    capabilities = "cap_net_raw,cap_net_admin=eip";
    source = "${pkgs.sniffnet}/bin/sniffnet";
  };

  # No perl messing with my /etc
  system.etc.overlay.enable = true;

  security.rtkit.enable = true;
}
