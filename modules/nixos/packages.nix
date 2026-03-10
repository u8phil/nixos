{
  lib,
  pkgs,
  ...
}:

{
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];

  security.sudo.enable = false;
  security.sudo-rs.enable = true;

  environment.systemPackages = with pkgs; [
    fish
    wget
    btop
    git
    sops
    openvpn3
    file
    (lib.hiPrio pkgs.uutils-coreutils-noprefix)
  ];
}
