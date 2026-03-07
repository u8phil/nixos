{ ... }:

{
  programs.plasma.panels = [
    {
      location = "bottom";
      height = 40;
      widgets = [
        {
          kickoff = {
            sortAlphabetically = true;
            icon = "nix-snowflake-white";
          };
        }
        {
          iconTasks.launchers = [
            "applications:org.kde.dolphin.desktop"
            "applications:floorp.desktop"
          ];
        }
        "org.kde.plasma.pager"
        "org.kde.plasma.marginsseparator"
        {
          systemTray.items = {
            shown = [
              "org.kde.plasma.battery"
              "org.kde.plasma.bluetooth"
              "org.kde.plasma.networkmanagement"
              "org.kde.plasma.volume"
            ];
            hidden = [ "org.kde.plasma.clipboard" ];
          };
        }
        {
          digitalClock.time.showSeconds = "always";
        }
      ];
    }
  ];
}
