{
  lib,
  pkgs,
  ...
}:

{
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];

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
