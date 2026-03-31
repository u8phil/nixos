{ pkgs, ... }:
{
  imports = [
    ./alacritty.nix
    ./floorp.nix
    ./github-mcp.nix
    ./keepassxc.nix
    ./ssh.nix
    ./plasma
    ./rclone.nix
    ./discord.nix
    ./opencode.nix
    ./vscodium.nix
    ./helix.nix
    ./freecad.nix
  ];

  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
  };
  sops = {
    defaultSopsFile = ../secrets/work-vpn.yaml;
    defaultSopsFormat = "yaml";

    age.sshKeyPaths = [
      "/var/lib/sops-nix/keys/sops-nix-ssh"
    ];
  };

  home.packages = with pkgs; [
    nixd
    devenv
    rust-bin.stable.latest.default
    mcp-nixos
    zellij
    gitui
    gearlever
    appimage-run
    qbittorrent
    jetbrains.rust-rover
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
