{
  pkgs,
  ...
}:
{
  services.xserver = {
    enable = true;
    excludePackages = [ pkgs.xterm ];
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.orca.enable = false;
  services.speechd.enable = false;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  programs.xwayland.enable = true;

  # Plasma enables the mail, contacts, calendar, and Akonadi bundle by default.
  programs.kde-pim.enable = false;

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    konsole
    kate
    elisa
    krdp
    khelpcenter
    discover
    baloo
    baloo-widgets
    plasma-systemmonitor
  ];
}
