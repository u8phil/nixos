{ config, pkgs, ... }:
let
  firefoxClassicLogo = pkgs.fetchurl {
    url = "https://upload.wikimedia.org/wikipedia/commons/8/84/Mozilla_Firefox_3.5_logo.png";
    hash = "sha256-9EOE521nTOFzTkpGf912J9IH4WNUoBqLqdybTwnMzRc=";
  };

  # Same logo, red-tinted, to tell the unproxied browser apart at a glance.
  firefoxDirectLogo =
    pkgs.runCommand "firefox-direct-logo.png" { nativeBuildInputs = [ pkgs.imagemagick ]; }
      ''
        magick ${firefoxClassicLogo} -resize 256x256 \
          -channel RGB -colorspace gray -colorspace sRGB \
          -fill '#d01818' -tint 110 +channel "$out"
      '';
in
{
  programs.librewolf.package = pkgs.librewolf.overrideAttrs (oldAttrs: {
    desktopItem = oldAttrs.desktopItem.override {
      desktopName = "Firefox";
      icon = "${firefoxClassicLogo}";
      # Plasma's task manager matches a window's resourceName (the executable,
      # "librewolf" for both instances) against StartupWMClass before its
      # app_id, which pulled Firefox (Direct) into this entry. Without it, the
      # default window still matches by desktop file name (app_id "librewolf").
      startupWMClass = null;
    };
  });

  # Runs the "direct" profile as its own instance. MOZ_APP_REMOTINGNAME sets
  # the Wayland app_id (KDE shows it as a separate task with its own icon) and
  # the remote-instance name (never hands off to the proxied instance).
  # --name only affects X11 WM_CLASS, so it's not enough on Wayland.
  xdg.desktopEntries.librewolf-direct = {
    name = "Firefox (Direct)";
    genericName = "Web Browser";
    exec = "env MOZ_APP_REMOTINGNAME=librewolf-direct ${config.programs.librewolf.finalPackage}/bin/librewolf -P direct %U";
    icon = "${firefoxDirectLogo}";
    terminal = false;
    categories = [
      "Network"
      "WebBrowser"
    ];
    settings.StartupWMClass = "librewolf-direct";
  };
}
