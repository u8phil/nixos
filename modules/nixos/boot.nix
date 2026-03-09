{ lib, pkgs, ... }:

{
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    useOSProber = true;
  };

  boot.loader.systemd-boot.enable = false;
  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot/efi";
  };

  fileSystems."/boot/efi".options = lib.mkAfter [
    "nofail"
    "x-systemd.automount"
    "x-systemd.idle-timeout=1min"
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
}
