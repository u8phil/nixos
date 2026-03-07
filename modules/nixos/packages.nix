{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];

  environment.systemPackages = with pkgs; [
    fish
    wget
    git
    sops
    openvpn3
    file
  ];
}
