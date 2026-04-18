{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./dolphin.nix
    ./shortcuts.nix
    ./panels/bottom.nix
    ./panels/stats.nix
  ];

  qt = {
    enable = true;
    platformTheme.name = "kde";
    style = {
      name = "Darkly";
      package = [
        pkgs.darkly-qt5
        pkgs.darkly
      ];
    };
  };

  programs.plasma = {
    enable = true;
    overrideConfig = true;
    resetFilesExclude = [
      "dolphinrc"
      "plasma-org.kde.plasma.desktop-appletsrc"
    ];

    workspace = {
      theme = "Darkly";
      colorScheme = "BreezeDark";
      widgetStyle = "Darkly";
      windowDecorations = {
        library = "org.kde.darkly";
        theme = "Darkly";
      };
    };

    input.keyboard = {
      layouts = [
        { layout = "us"; }
        { layout = "ru"; }
      ];
      options = [ "grp:alt_shift_toggle" ];
      switchingPolicy = "global";
    };

    input.touchpads = [
      {
        name = "PNP0C50:0b 0911:5288 Touchpad";
        vendorId = "0911";
        productId = "5288";
        naturalScroll = true;
      }
    ];

    session.general.askForConfirmationOnLogout = false;
    session.sessionRestore.restoreOpenApplicationsOnLogin = "startWithEmptySession";

    kwin = {
      edgeBarrier = 0;
      cornerBarrier = false;
      effects.blur.enable = false;
      effects.shakeCursor.enable = false;
      effects.desktopSwitching.animation = "fade";
    };

    krunner.position = "center";
    kwin.virtualDesktops.number = 4;

    configFile = {
      kdeglobals.General = {
        TerminalApplication = "Alacritty";
        TerminalService = "Alacritty.desktop";
      };

      baloofilerc."Basic Settings"."Indexing-Enabled" = {
        value = false;
        immutable = true;
      };
      plasmarc.OSD.kbdLayoutChangedEnabled = false;

      darklyrc.Common.FloatingTitlebar = false;

      # used for wifi passwords
      kwalletrc.Wallet.Enabled = true;

      kscreenlockerrc.Daemon = {
        Autolock = true;
        Timeout = 15;
        LockOnResume = true;
      };

      kwinrc = {
        Plugins.better_blur_dxEnabled = true;
        TabBox.DelayTime = 0;
        TabBox.LayoutName = "big_icons";
        TabBoxAlternative.LayoutName = "big_icons";
        ModifierOnlyShortcuts.Meta = "org.kde.kglobalaccel,/component/org_kde_krunner_desktop,org.kde.kglobalaccel.Component,invokeShortcut,_launch";

        "Effect-overview" = {
          BorderActivate = {
            value = "";
            immutable = true;
          };
        };
      };
    };
  };

  home.packages = with pkgs; [
    unrar # for ark to support rar
    kdePackages.kcalc
  ];

  xdg.configFile."systemd/user/plasma-baloorunner.service".source =
    config.lib.file.mkOutOfStoreSymlink "/dev/null";

  systemd.user.services.krunner-daemon = {
    Unit = {
      Description = "Start KRunner daemon";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      # don't make the daemon oneshot
      ExecStart = "${pkgs.kdePackages.plasma-workspace}/bin/krunner --daemon";
      RemainAfterExit = true;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };

}
