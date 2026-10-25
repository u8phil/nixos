{ pkgs, ... }:
let
  firefoxClassicLogo = pkgs.fetchurl {
    url = "https://upload.wikimedia.org/wikipedia/commons/8/84/Mozilla_Firefox_3.5_logo.png";
    hash = "sha256-9EOE521nTOFzTkpGf912J9IH4WNUoBqLqdybTwnMzRc=";
  };
in
{
  programs.librewolf.package = pkgs.librewolf.overrideAttrs (oldAttrs: {
    desktopItem = oldAttrs.desktopItem.override {
      desktopName = "Firefox";
      icon = "${firefoxClassicLogo}";
    };
  });
}
