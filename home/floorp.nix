{
  config,
  lib,
  ...
}:
let
  floorpKeyboardShortcutConfig = builtins.toJSON {
    enabled = true;
    shortcuts = {
      "alt-q-previous-tab" = {
        modifiers = {
          alt = true;
          ctrl = false;
          meta = false;
          shift = false;
        };
        key = "Q";
        action = "gecko-show-previous-tab";
      };
      "alt-w-next-tab" = {
        modifiers = {
          alt = true;
          ctrl = false;
          meta = false;
          shift = false;
        };
        key = "W";
        action = "gecko-show-next-tab";
      };
      "alt-r-reload-tab" = {
        modifiers = {
          alt = true;
          ctrl = false;
          meta = false;
          shift = false;
        };
        key = "R";
        action = "gecko-reload";
      };
      "alt-e-new-tab" = {
        modifiers = {
          alt = true;
          ctrl = false;
          meta = false;
          shift = false;
        };
        key = "E";
        action = "gecko-open-new-tab";
      };
      "alt-c-close-tab" = {
        modifiers = {
          alt = true;
          ctrl = false;
          meta = false;
          shift = false;
        };
        key = "C";
        action = "gecko-close-tab";
      };
    };
  };
in
{
  programs.floorp = {
    enable = true;
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      Preferences = {
        "floorp.keyboardshortcut.enabled" = {
          Value = true;
          Status = "locked";
        };
        "floorp.keyboardshortcut.config" = {
          Value = floorpKeyboardShortcutConfig;
          Status = "locked";
        };
      };
      ExtensionSettings = {
        "*" = {
          installation_mode = "allowed";
        };
        "keepassxc-browser@keepassxc.org" = {
          installation_mode = "normal_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4628286/keepassxc_browser-1.9.11.xpi";
        };
        "adnauseam@rednoise.org" = {
          installation_mode = "normal_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4696939/adnauseam-3.28.2.xpi";
        };
      };
    };
  };

  home.file.".local/share/applications/floorp.desktop".text = lib.mkForce (
    builtins.replaceStrings [ "Name=Floorp" ] [ "Name=Firefox" ] (
      builtins.readFile "${config.programs.floorp.package.desktopItem}/share/applications/floorp.desktop"
    )
  );
}
