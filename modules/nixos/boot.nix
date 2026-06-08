{ inputs, pkgs, ... }:
{

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    useOSProber = true;
    theme = inputs.nixos-grub-themes.packages.${pkgs.system}.nixos;
  };

  # my laptop is shit
  # - amd_sfh: AMD Sensor Fusion Hub (broken on this laptop, hangs)
  # - tpm, tpm_tis: TPM init adds ~3s to boot, unused (no LUKS-with-TPM, no attestation)
  boot.blacklistedKernelModules = [
    "amd_sfh"
    "tpm"
    "tpm_tis"
  ];
  # Disable legacy 8250 serial port probing (~3s boot delay × 4 ports).
  # Does NOT affect USB serial (cdc_acm/cp210x/ch341) used for ESP32 etc.
  boot.kernelParams = [ "8250.nr_uarts=0" ];
  boot.loader.timeout = 0;
  # boot.kernel = pkgs.linuxPa
  # boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto;
  # nix.settings.substituters = [
  #   "https://attic.xuyh0120.win/lantian"
  # ];
  # nix.settings.trusted-public-keys = [
  #   "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
  # ];

  boot.initrd.systemd.enable = true;

  system.nixos-init.enable = true;
  services.userborn.enable = true;

  boot.loader.efi = {
    canTouchEfiVariables = true;
    # do not use efiSysMountPoint, it fucks with predefined boot in hardware conf
  };
}
