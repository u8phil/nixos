# Single source of truth for installed extensions and toolbar placement.
# extensions.nix, toolbar.nix and policies.nix all read this file.
let
  extensions = {
    keepass = {
      id = "keepassxc-browser@keepassxc.org";
      slug = "keepassxc-browser";
    };
    adnauseam = {
      id = "adnauseam@rednoise.org";
      slug = "adnauseam";
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
    disableVisibility = {
      id = "{DEBA3021-9876-4702-89BA-42D095339A0A}";
      slug = "disable-page-visibility";
    };
    proxy = {
      id = "proxytoggle@devpg.net";
      slug = "proxy_toggle";
      # Defaults imported on the first restart after install, if storage is empty.
      initialSettings = {
        proxySettings = {
          type = "socks";
          host = "127.0.0.1";
          port = 1080;
          username = "";
          password = "";
          proxyDNS = true;
        };
      };
      # proxy.settings.set() throws unless the extension has private-browsing
      # access, so the toggle is dead in incognito without this grant.
      private_browsing = true;
    };
  };
in
{
  inherit extensions;

  # Toolbar groups, in display order. An installed extension omitted here
  # (e.g. disableVisibility) stays installed but is not placed on any toolbar.
  toolbar = {
    navBar = [
      extensions.proxy
      extensions.darkreader
      extensions.keepass
    ];
    menu = [
      extensions.sponsor
      extensions.sevenTV
      extensions.adnauseam
      extensions.noTranslation
    ];
  };
}
