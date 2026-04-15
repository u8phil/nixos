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

  nix.gc = {
    automatic = true;
    dates = "*-*-1/3 03:15:00";
    options = "--delete-older-than 14d";
  };

  nix.optimise.automatic = true;
  programs.nix-ld.enable = true;

  system.stateVersion = "25.11";
}
