{ lib, ... }:
let
  addons = import ./addons.nix;

  # Firefox's widget-ID transformation for an extension record's ID:
  # lowercase, then replace anything outside [a-z0-9_-] with "_".
  action =
    extension:
    "${lib.stringAsChars (c: if builtins.match "[a-z0-9_-]" c != null then c else "_") (
      lib.toLower extension.id
    )}-browser-action";

  # Keep the original toolbar layout, excluding Floorp's status bar and
  # workspaces/profile-manager buttons.
  placements = {
    "widget-overflow-fixed-list" = [ ];
    "unified-extensions-area" = map action addons.toolbar.menu;
    # Preserve the original URL-bar spacing and button order.
    "nav-bar" = [
      "customizableui-special-spring1"
      "customizableui-special-spring3"
      "vertical-spacer"
      "urlbar-container"
      "unified-extensions-button"
    ]
    ++ map action addons.toolbar.navBar
    ++ [ "downloads-button" ];
    "toolbar-menubar" = [ "menubar-items" ];
    "TabsToolbar" = [
      "tabbrowser-tabs"
      "new-tab-button"
      "alltabs-button"
    ];
    "vertical-tabs" = [ ];
    "PersonalToolbar" = [
      "import-button"
      "personal-bookmarks"
    ];
  };
in
{
  # Home Manager encodes attrset prefs as JSON strings.
  programs.librewolf.profiles.default.settings."browser.uiCustomization.state" = {
    inherit placements;
    seen = map action (addons.toolbar.navBar ++ addons.toolbar.menu) ++ [
      "developer-button"
      "undo-closed-tab"
      "screenshot-button"
    ];
    dirtyAreaCache = builtins.attrNames placements;
    # CustomizableUI.sys.mjs kVersion in LibreWolf 158.0-1; recheck on upgrades.
    currentVersion = 28;
    # The next generated special-widget ID must follow the existing spring3.
    newElementCount = 3;
  };
}
