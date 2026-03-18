{ pkgs, ... }:
{
  imports = [
    ./alacritty.nix
    ./floorp.nix
    ./keepassxc.nix
    ./ssh.nix
    ./plasma
    ./rclone.nix
    ./discord.nix
    ./opencode.nix
    ./vscodium.nix
    ./helix.nix
  ];

  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
  };

  home.packages = with pkgs; [
    nixd
    devenv
    steam
    mcp-nixos
    github-mcp-server
    telegram-desktop
    alacritty
    nixfmt
    tokei
    pinta
    gparted
    hysteria
    sniffnet
    baobab
    wl-clipboard
  ];

  xdg.autostart.enable = true;

  # button control from bluetooth headphones
  services.mpris-proxy.enable = true;
  home.stateVersion = "25.11";
}
