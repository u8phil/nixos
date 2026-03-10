{ inputs, pkgs, ... }:
{
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    useOSProber = true;
    theme = inputs.nixos-grub-themes.packages.${pkgs.system}.nixos;
  };

  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot/efi";
  };
}
