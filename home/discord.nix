{ pkgs, ... }:
{

  programs.vesktop = {
    package =
      (pkgs.extend (
        _: prev: {
          vesktop = prev.vesktop.overrideAttrs (oldAttrs: {
            desktopItems =
              let
                proxy = "socks5://127.0.0.1:1080";
              in
              map (
                desktopItem:
                desktopItem.override {
                  desktopName = "Discord";
                  exec = "env http_proxy=${proxy} https_proxy=${proxy} vesktop --proxy-server=\"${proxy}\" %U";
                }
              ) (oldAttrs.desktopItems or [ ]);
          });
        }
      )).vesktop;
    enable = true;
    settings = {
      checkUpdates = false;
      customTitleBar = true;
      disableMinSize = true;
      minimizeToTray = true;
      tray = true;
      splashTheming = true;
      staticTitle = true;
      hardwareAcceleration = true;
      discordBranch = "stable";
    };
  };
}
