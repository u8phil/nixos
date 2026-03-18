{ pkgs, ... }:

{
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    konsole
    kate
    elisa
    pkgs.xterm
    discover
    baloo
    baloo-widgets
  ];
}
