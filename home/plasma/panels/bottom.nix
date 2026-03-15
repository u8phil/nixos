{ ... }:

{
  programs.plasma.panels = [
    {
      location = "bottom";
      extraSettings = ''
        panel.height = 34;
        panel.alignment = "center";
        panel.hiding = "windowsgobelow";
        panel.lengthMode = "fit";
        panel.offset = 0;
        panel.floating = false;

        const panelViews = new ConfigFile("plasmashellrc", "PlasmaViews");
        const panelView = new ConfigFile(panelViews, "Panel " + panel.id);
        const panelDefaults = new ConfigFile(panelView, "Defaults");

        panelView.writeEntry("alignment", 132);
        panelView.writeEntry("panelVisibility", 3);
        panelView.writeEntry("panelLengthMode", 1);
        panelView.writeEntry("floating", 0);
        panelDefaults.writeEntry("thickness", 34);
        panelDefaults.writeEntry("offset", 0);
      '';
      widgets = [
        {
          kickoff = {
            sortAlphabetically = true;
            icon = "nix-snowflake-white";
          };
        }
        {
          iconTasks = {
            launchers = [
              "applications:org.telegram.desktop.desktop"
              "applications:org.kde.dolphin.desktop"
              "applications:floorp.desktop"
            ];
            appearance.iconSpacing = "small";
          };
        }
        "org.kde.plasma.pager"
        "org.kde.plasma.marginsseparator"
        {
          systemTray.items = {
            extra = [
              "org.kde.plasma.battery"
              "org.kde.plasma.bluetooth"
              "org.kde.plasma.networkmanagement"
              "org.kde.plasma.volume"
              "org.kde.plasma.brightness"
              "org.kde.plasma.clipboard"
            ];
            shown = [
              "org.kde.plasma.battery"
              "org.kde.plasma.bluetooth"
              "org.kde.plasma.networkmanagement"
              "org.kde.plasma.volume"
            ];
            hidden = [
              "org.kde.plasma.brightness"
              "org.kde.plasma.clipboard"
            ];
          };
        }
        {
          digitalClock.time.showSeconds = "always";
        }
      ];
    }
  ];
}
