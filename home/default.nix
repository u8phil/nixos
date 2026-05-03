{ pkgs, ... }:
{
  imports = [
    ./ai
    ./floorp.nix
    ./keepassxc.nix
    ./ssh.nix
    ./plasma
    ./rclone.nix
    ./discord.nix
    ./vscodium.nix
    ./helix.nix
    ./freecad.nix
    ./alacritty.nix
    ./zed.nix
    ./matlab.nix
  ];

  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
    silent = true;
    nix-direnv.enable = true;
  };
  sops = {
    defaultSopsFile = ../secrets/work-vpn.yaml;
    defaultSopsFormat = "yaml";

    age.sshKeyPaths = [
      "/var/lib/sops-nix/keys/sops-nix-ssh"
    ];
  };

  home.packages = with pkgs; [
    nodejs
    nixd
    devenv
    rust-bin.stable.latest.default
    # mcp-nixos
    zellij
    gitui
    gearlever
    appimage-run
    qbittorrent
    jetbrains.rust-rover
    telegram-desktop
    nixfmt
    tokei
    pinta
    gparted
    hysteria
    sniffnet
    baobab
    wl-clipboard
  ];

  programs.mpv = {
    enable = true;
    package = pkgs.mpv.override {
      youtubeSupport = false;
    };
  };

  xdg.autostart.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
    configPackages = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
  };

  # button control from bluetooth headphones
  services.mpris-proxy.enable = true;
  home.stateVersion = "25.11";
}
