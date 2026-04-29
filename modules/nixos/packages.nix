{
  lib,
  pkgs,
  ...
}:

{
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/phil/nixos";
  };

  programs.nix-index-database.comma.enable = true;
  services.envfs.enable = true;

  environment.systemPackages = with pkgs; [
    fish
    wget
    btop
    git
    ripgrep
    sops
    file
    (lib.hiPrio pkgs.uutils-coreutils-noprefix)
  ];
}
