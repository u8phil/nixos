{ inputs, pkgs, ... }:
{

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    useOSProber = true;
    theme = inputs.nixos-grub-themes.packages.${pkgs.system}.nixos;
  };

  boot.loader.timeout = 1;

  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;
  nix.settings.substituters = [
    "https://attic.xuyh0120.win/lantian"
  ];
  nix.settings.trusted-public-keys = [
    "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
  ];

  boot.initrd.systemd.enable = true;

  system.nixos-init.enable = true;
  services.userborn.enable = true;

  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot/efi";
  };
}
