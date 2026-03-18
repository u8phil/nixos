{ lib, ... }:

{
  programs.plasma = {
    resetFiles = lib.mkAfter [ "plasma-org.kde.plasma.desktop-appletsrc" ];

    configFile = {
      "plasma-org.kde.plasma.desktop-appletsrc" = {
        "ActionPlugins/1"."RightButton;NoModifier" = "org.kde.contextmenu";

        "Containments/1505" = {
          activityId = "";
          formfactor = 2;
          immutability = 1;
          lastScreen = 0;
          location = 4;
          plugin = "org.kde.panel";
          wallpaperplugin = "org.kde.image";
        };

        "Containments/1505/Applets/1506" = {
          immutability = 1;
          plugin = "org.kde.plasma.kickoff";
        };

        "Containments/1505/Applets/1506/Configuration" = {
          popupHeight = 400;
          popupWidth = 560;
        };

        "Containments/1505/Applets/1506/Configuration/General" = {
          alphaSort = true;
          favoritesPortedToKAstats = true;
          icon = "nix-snowflake-white";
        };

        "Containments/1505/Applets/1507" = {
          immutability = 1;
          plugin = "org.kde.plasma.icontasks";
        };

        "Containments/1505/Applets/1507/Configuration/General" = {
          forceStripes = false;
          iconSpacing = 0;
          launchers = "applications:org.telegram.desktop.desktop,applications:org.kde.dolphin.desktop,applications:floorp.desktop";
        };

        "Containments/1505/Applets/1508" = {
          immutability = 1;
          plugin = "org.kde.plasma.pager";
        };

        "Containments/1505/Applets/1509" = {
          immutability = 1;
          plugin = "org.kde.plasma.marginsseparator";
        };

        "Containments/1505/Applets/1510" = {
          activityId = "";
          formfactor = 0;
          immutability = 1;
          lastScreen = (-1);
          location = 0;
          plugin = "org.kde.plasma.systemtray";
          popupHeight = 432;
          popupWidth = 432;
          wallpaperplugin = "org.kde.image";
        };

        "Containments/1505/Applets/1510/Applets/1513" = {
          immutability = 1;
          plugin = "org.kde.plasma.clipboard";
        };

        "Containments/1505/Applets/1510/Applets/1521" = {
          immutability = 1;
          plugin = "org.kde.plasma.networkmanagement";
        };

        "Containments/1505/Applets/1510/Applets/1522" = {
          immutability = 1;
          plugin = "org.kde.plasma.volume";
        };

        "Containments/1505/Applets/1510/Applets/1522/Configuration/General".migrated = true;

        "Containments/1505/Applets/1510/Applets/1524" = {
          immutability = 1;
          plugin = "org.kde.plasma.battery";
        };

        "Containments/1505/Applets/1510/Applets/1525" = {
          immutability = 1;
          plugin = "org.kde.plasma.brightness";
        };

        "Containments/1505/Applets/1510/Applets/1526" = {
          immutability = 1;
          plugin = "org.kde.plasma.bluetooth";
        };

        "Containments/1505/Applets/1510/General" = {
          extraItems = "org.kde.plasma.battery,org.kde.plasma.bluetooth,org.kde.plasma.networkmanagement,org.kde.plasma.volume,org.kde.plasma.brightness,org.kde.plasma.clipboard";
          hiddenItems = "org.kde.plasma.brightness,org.kde.plasma.clipboard";
          knownItems = "org.kde.plasma.cameraindicator,org.kde.plasma.devicenotifier,org.kde.plasma.clipboard,org.kde.plasma.mediacontroller,org.kde.plasma.manage-inputmethod,org.kde.plasma.notifications,org.kde.kscreen,org.kde.plasma.keyboardindicator,org.kde.plasma.keyboardlayout,org.kde.plasma.battery,org.kde.plasma.printmanager,org.kde.plasma.brightness,org.kde.plasma.weather,org.kde.plasma.networkmanagement,org.kde.plasma.bluetooth,org.kde.plasma.volume";
          shownItems = "org.kde.plasma.battery,org.kde.plasma.bluetooth,org.kde.plasma.networkmanagement,org.kde.plasma.volume";
        };

        "Containments/1505/Applets/1523" = {
          immutability = 1;
          plugin = "org.kde.plasma.digitalclock";
        };

        "Containments/1505/Applets/1523/Configuration" = {
          popupHeight = 400;
          popupWidth = 560;
        };

        "Containments/1505/Applets/1523/Configuration/Appearance" = {
          autoFontAndSize = true;
          showSeconds = 2;
        };

        "Containments/1505/General".AppletOrder = "1506;1507;1508;1509;1510;1523";
      };

      plasmashellrc = {
        "PlasmaViews/Panel 1505" = {
          alignment = 132;
          floating = 0;
          panelLengthMode = 1;
          panelVisibility = 2;
        };

        "PlasmaViews/Panel 1505/Defaults" = {
          offset = 0;
          thickness = 40;
        };
      };
    };
  };
}
