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

      kwinrc = {
        TabBox.DelayTime = 0;
        TabBox.LayoutName = "big_icons";
        TabBoxAlternative.LayoutName = "big_icons";
        ModifierOnlyShortcuts.Meta = "org.kde.krunner,/App,,toggleDisplay";

        "Effect-overview" = {
          BorderActivate = {
            value = "";
            immutable = true;
          };
        };
      };
    };

    startup.desktopScript.fix_krunner_meta = {
      priority = 1;
      runAlways = true;
      text = ''
        const launcherTypes = [
          "org.kde.plasma.kickoff",
          "org.kde.plasma.kicker",
          "org.kde.plasma.kickerdash"
        ];
        const globalShortcuts = new ConfigFile("kglobalshortcutsrc", "plasmashell");

        panels().forEach((panel) => {
          panel.widgets().forEach((widget) => {
            if (launcherTypes.includes(widget.type)) {
              widget.globalShortcut = "";
              globalShortcuts.writeEntry("activate widget " + panel.id, "none,,");
            }
          });
        });
      '';
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
