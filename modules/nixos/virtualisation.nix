{ lib, ... }:

{
  programs.virt-manager.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    # NixOS module hardcodes `--timeout 120` (2min). Appending another
    # `--timeout 21600` (6h) here — libvirtd's getopt parses left-to-right
    # so the later value wins.
    extraOptions = [
      "--timeout"
      "21600"
    ];
  };

  users.users.phil.extraGroups = [
    "libvirtd"
  ];

  # Socket-activate libvirtd: service starts only on first connect (virt-manager,
  # virsh, etc.). Idle-shutdown handled by `--timeout` above.
  systemd.services.libvirtd.wantedBy = lib.mkForce [ ];
  systemd.sockets.libvirtd.wantedBy = [ "sockets.target" ];
  systemd.sockets.libvirtd-ro.wantedBy = [ "sockets.target" ];
  systemd.sockets.libvirtd-admin.wantedBy = [ "sockets.target" ];
}
