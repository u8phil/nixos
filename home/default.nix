{
  pkgs,
  ...
}:
{
  imports = [
    ./alacritty.nix
    ./floorp.nix
    ./keepassxc.nix
    ./ssh.nix
    ./zed.nix
    ./plasma
    ./rclone.nix
    ./discord.nix
    ./opencode.nix
  ];

  home.packages = with pkgs; [
    nixd
    telegram-desktop
    alacritty
    nixfmt
    tokei
    hysteria
    sniffnet
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
