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
    openvpn3
    file
    (lib.hiPrio pkgs.uutils-coreutils-noprefix)
  ];
}
