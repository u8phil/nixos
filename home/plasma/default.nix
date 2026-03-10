{ pkgs, ... }:
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

    session.general.askForConfirmationOnLogout = false;
    session.sessionRestore.restoreOpenApplicationsOnLogin = "startWithEmptySession";

    kwin = {
      edgeBarrier = 0;
      cornerBarrier = false;
      effects.shakeCursor.enable = false;
      effects.desktopSwitching.animation = "fade";
    };

    krunner.position = "center";
    kwin.virtualDesktops.number = 4;

    configFile = {
      kscreenlockerrc.Daemon = {
        Autolock = true;
        Timeout = 15;
        LockOnResume = true;
      };

      kwinrc.TabBox.DelayTime = 0;
      kwinrc.TabBox.LayoutName = "big_icons";
      kwinrc.TabBoxAlternative.LayoutName = "big_icons";

      kwinrc."Effect-overview" = {
        BorderActivate = {
          value = "";
          immutable = true;
        };
      };
    };
  };

  systemd.user.services.krunner-daemon = {
    Unit = {
      Description = "Start KRunner daemon";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.kdePackages.plasma-workspace}/bin/krunner --daemon";
      RemainAfterExit = true;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}
