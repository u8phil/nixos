{ pkgs, ... }:
let
  nixWithProxy = pkgs.writeShellScriptBin "nix" ''
    exec env \
      http_proxy=http://127.0.0.1:18081 \
      HTTP_PROXY=http://127.0.0.1:18081 \
      https_proxy=http://127.0.0.1:18081 \
      HTTPS_PROXY=http://127.0.0.1:18081 \
      no_proxy=localhost,127.0.0.1 \
      NO_PROXY=localhost,127.0.0.1 \
      ${pkgs.nix}/bin/nix "$@"
  '';
in
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
    ./mpv.nix
    ./alacritty.nix
    ./zed.nix
    ./thunderbird.nix
    # Disable matlab, but it's good to know how to use it under nixos
    # ./matlab.nix
  ];

  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
    silent = true;
    nix-direnv.enable = true;
  };

  home.file.".config/fish/conf.d/devenv.fish".text = ''
    devenv hook fish | source
  '';

  sops = {
    defaultSopsFile = ../secrets/work-vpn.yaml;
    defaultSopsFormat = "yaml";

    age.sshKeyPaths = [
      "/var/lib/sops-nix/keys/sops-nix-ssh"
    ];
  };

  home.packages = with pkgs; [
    (lib.hiPrio nixWithProxy)
    nixd
    devenv
    rust-bin.stable.latest.default
    gitui
    pdfarranger
    prismlauncher
    qbittorrent
    jetbrains.rust-rover
    telegram-desktop
    (wrapOBS {
      plugins = [ obs-studio-plugins.obs-pipewire-audio-capture ];
    })
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
  ];

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
