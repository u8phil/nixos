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
  ];

  home.packages = with pkgs; [
    nixd
    mcp-nixos
    github-mcp-server
    telegram-desktop
    alacritty
    nixfmt
    tokei
    hysteria
    sniffnet
    baobab
    wl-clipboard
  ];

  xdg.autostart = {
    enable = true;
    entries = [
      "${pkgs.telegram-desktop}/share/applications/org.telegram.desktop.desktop"
    ];
  };

  # button control from bluetooth headphones
  services.mpris-proxy.enable = true;
  home.stateVersion = "25.11";
}
