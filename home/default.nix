{ pkgs, ... }:
{
  imports = [
    ./ai
    ./git.nix
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
    # Disable matlab, but it's good to know how to use it under nixos
    # ./matlab.nix
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
    zellij
    gitui
    pdfarranger
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
    # System monitor replacement for KDE's bundled Plasma System Monitor.
    resources
    baobab
    wl-clipboard
    libreoffice
    wild-unwrapped
    clang
  ];

  # Wild linker as default for Rust builds via cargo.
  # `clang` invokes `wild` via --ld-path. Both must be on PATH (above).
  home.file.".cargo/config.toml".text = ''
    [target.x86_64-unknown-linux-gnu]
    linker = "clang"
    rustflags = ["-Clink-arg=--ld-path=wild"]
  '';

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
