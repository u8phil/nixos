# Single source of truth for installed extensions and toolbar placement.
# extensions.nix, toolbar.nix and policies.nix all read this file.
let
  extensions = {
    keepass = {
      id = "keepassxc-browser@keepassxc.org";
      slug = "keepassxc-browser";
    };
    ublock = {
      id = "uBlock0@raymondhill.net";
      slug = "ublock-origin";
      private_browsing = true;
    };
    sponsor = {
      id = "sponsorBlocker@ajay.app";
      slug = "sponsorblock";
    };
    sevenTV = {
      id = "moz-addon-prod@7tv.app";
      slug = "7tv-extension";
    };
    darkreader = {
      id = "addon@darkreader.org";
      slug = "darkreader";
    };
    noTranslation = {
      id = "{9a3104a2-02c2-464c-b069-82344e5ed4ec}";
      slug = "youtube-no-translation";
    };
  };
in
{
  inherit extensions;

  # Toolbar groups, in display order. An installed extension omitted here
  # stays installed but is not placed on any toolbar.
  toolbar = {
    navBar = [
      extensions.darkreader
      extensions.keepass
    ];
    menu = [
      extensions.sponsor
      extensions.sevenTV
      extensions.ublock
      extensions.noTranslation
    ];
  };
}
