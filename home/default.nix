{
  pkgs,
  ...
}:
{
  imports = [
    ./modules/alacritty.nix
    ./modules/spice-vdagent.nix
    ./floorp.nix
    ./keepassxc.nix
    ./ssh.nix
    ./zed.nix
    ./plasma
    ./rclone.nix
    ./discord.nix
  ];

  home.packages = with pkgs; [
    nixd
    telegram-desktop
    alacritty
    nixfmt
    tokei
    hysteria
    (pkgs.writeShellScriptBin "opencode" ''
      set -euo pipefail

      export HTTP_PROXY="http://127.0.0.1:18081"
      export HTTPS_PROXY="$HTTP_PROXY"

      env HTTP_PROXY="http://127.0.0.1:18081" HTTPS_PROXY="http://127.0.0.1:18081" \
        ${pkgs.opencode}/bin/opencode "$@"
    '')
  ];

  xdg.autostart = {
    enable = true;
    entries = [
      "${pkgs.telegram-desktop}/share/applications/org.telegram.desktop.desktop"
    ];
  };

  home.stateVersion = "25.11";
}
