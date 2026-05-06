{ ... }:

{
  nixpkgs.config.allowUnfree = true;

  documentation.man.cache.enable = false;
  documentation.enable = false;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.settings.trusted-users = [ "phil" ];
  nix.settings.extra-substituters = [
    "https://devenv.cachix.org"
  ];
  nix.settings.extra-trusted-public-keys = [
    "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
  ];

  nix.optimise.automatic = true;
  programs.nix-ld.enable = true;

  systemd.services.nix-daemon.environment = {
    http_proxy = "http://127.0.0.1:18081";
    https_proxy = "http://127.0.0.1:18081";
    no_proxy = "localhost,127.0.0.1";
  };

  system.stateVersion = "25.11";
}
