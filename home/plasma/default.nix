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

      kwinrc."Effect-overview" = {
        BorderActivate = {
          value = "";
          immutable = true;
        };
      };
    };
  };
}
