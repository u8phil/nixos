{
  ...
}:
{
  programs.keepassxc = {
    enable = true;
    autostart = true;
    settings = {
      General = {
        BackupBeforeSave = true;
        ConfigVersion = 2;
        DropToBackgroundOnCopy = true;
        HideWindowOnCopy = true;
        MinimizeAfterUnlock = true;
        MinimizeOnCopy = false;
        MinimizeOnOpenUrl = true;
      };

      Browser = {
        Enabled = true;
        SearchInAllDatabases = true;
      };

      FdoSecrets = {
        Enabled = false;
      };

      GUI = {
        ApplicationTheme = "dark";
        CompactMode = true;
        HideMenubar = false;
        HidePasswords = false;
        HidePreviewPanel = true;
        HideToolbar = false;
        MinimizeOnClose = true;
        MinimizeOnStartup = true;
        MinimizeToTray = true;
        ShowExpiredEntriesOnDatabaseUnlockOffsetDays = 5;
        ShowTrayIcon = true;
        TrayIconAppearance = "monochrome-light";
      };

      SSHAgent = {
        Enabled = true;
      };

      Security = {
        IconDownloadFallback = true;
        LockDatabaseIdle = true;
        LockDatabaseIdleSeconds = 600;
      };
    };
  };

  programs.plasma.shortcuts."services/org.keepassxc.KeePassXC.desktop" = {
    _launch = [ "Meta+K" ];
  };

  programs.plasma.window-rules = [
    {
      description = "Hide KeePassXC from screen captures";
      match = {
        window-class = {
          value = "keepassxc";
          type = "substring";
          match-whole = false;
        };
        window-types = [ "normal" ];
      };
      apply.excludefromcapture = {
        value = true;
        apply = "force";
      };
    }
  ];
}
