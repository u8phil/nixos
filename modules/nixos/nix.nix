{ ... }:

{
  nixpkgs.config.allowUnfree = true;

  documentation.man.cache.enable = false;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.gc = {
    automatic = true;
    dates = "*-*-1/3 03:15:00";
    options = "--delete-older-than 14d";
  };

  nix.optimise.automatic = true;

  system.stateVersion = "25.11";
}
