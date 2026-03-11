{ ... }:

{
  programs.plasma.shortcuts = {
    plasmashell = {
      "activate application launcher" = "Alt+F1";
      "manage activities" = "none";
    };

    kwin = {
      "Switch to Desktop 1" = "Alt+1";
      "Switch to Desktop 2" = "Alt+2";
      "Switch to Desktop 3" = "Alt+3";
      "Switch to Desktop 4" = "Alt+4";
    };

    "services/floorp.desktop" = {
      _launch = [ "Meta+F" ];
    };

    "services/Alacritty.desktop" = {
      _launch = [
        "Meta+C"
        "Meta+Enter"
      ];
    };

    "services/org.kde.krunner.desktop" = {
      _launch = [
        "Meta+Q"
      ];
      RunClipboard = "none";
    };

    "services/org.kde.plasma.emojier.desktop" = {
      _launch = "none";
    };
  };

  programs.plasma.spectacle.shortcuts.captureRectangularRegion = "Num+/";
}
