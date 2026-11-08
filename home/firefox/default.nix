{ config, ... }:
let
  defaultProfile = config.programs.librewolf.profiles.default;
in
{
  imports = [
    ./package.nix
    ./extensions.nix
    ./policies.nix
    ./settings.nix
    ./appearance.nix
    ./toolbar.nix
  ];

  programs.librewolf = {
    enable = true;
    # "Firefox": everything goes through Hysteria (SOCKS5 on :1080).
    profiles.default = {
      id = 0;
      isDefault = true;
      settings = {
        "network.proxy.type" = 1;
        "network.proxy.socks" = "127.0.0.1";
        "network.proxy.socks_port" = 1080;
        "network.proxy.socks_version" = 5;
        "network.proxy.socks_remote_dns" = true;
        # Fail closed if Hysteria is down instead of going direct.
        "network.proxy.failover_direct" = false;
        "network.proxy.no_proxies_on" = "";
      };
    };

    # "Firefox (Direct)": an exact copy of the default profile, minus the proxy.
    # Separate profile dir, so it runs alongside the default (own cookies).
    profiles.direct = {
      id = 1;
      inherit (defaultProfile) userChrome userContent;
      settings = defaultProfile.settings // {
        "network.proxy.type" = 0;
      };
    };
  };

  # Apps (e.g. Vesktop registering its discord:// handler, KDE "Open with")
  # rewrite mimeapps.list in place, turning the HM symlink into a regular
  # file. HM then backs it up to mimeapps.list.bak, and on the next rewrite the
  # existing .bak blocks activation. Declarations here are the source of
  # truth, so always overwrite instead of backing up.
  xdg.configFile."mimeapps.list".force = true;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = [ "librewolf.desktop" ];
      "application/xhtml+xml" = [ "librewolf.desktop" ];
      "x-scheme-handler/http" = [ "librewolf.desktop" ];
      "x-scheme-handler/https" = [ "librewolf.desktop" ];
    };
  };
}
