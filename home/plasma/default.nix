{ ... }:

{
  imports = [
    ./shortcuts.nix
    ./panels/bottom.nix
    ./panels/stats.nix
  ];

  programs.plasma = {
    enable = true;

    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      colorScheme = "BreezeDark";
    };

    session.sessionRestore.restoreOpenApplicationsOnLogin = "startWithEmptySession";

    kwin = {
      edgeBarrier = 0;
      cornerBarrier = false;
    };

    configFile = {
      kscreenlockerrc.Daemon = {
        Autolock = true;
        Timeout = 15;
        LockOnResume = true;
      };

      kwinrc.Desktops.Number = {
        value = 4;
        immutable = true;
      };

      kwinrc.ElectricBorders = {
        Top = "None";
        TopRight = "None";
        Right = "None";
        BottomRight = "None";
        Bottom = "None";
        BottomLeft = "None";
        Left = "None";
        TopLeft = "None";
      };
    };
  };
}
