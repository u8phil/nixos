{
  config,
  pkgs,
  ...
}:
let
  inherit (config.lib.formats.rasi) mkLiteral;
in
{
  programs.rofi = {
    enable = true;

    terminal = "${pkgs.alacritty}/bin/alacritty";
    location = "top";
    yoffset = 20;
  };

  xdg.desktopEntries.rofi = {
    name = "Rofi";
    genericName = "Application Launcher";
    exec = "${pkgs.rofi}/bin/rofi -show drun";
    terminal = false;
    icon = "system-run";
    categories = [
      "Utility"
      "System"
    ];
  };

  programs.plasma.shortcuts."services/rofi.desktop" = {
    _launch = [ "Meta+Q" "Metz" ];
    RunClipboard = "none";
  };
}
