{
  config,
  lib,
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
  ];

  home.packages = with pkgs; [
    nil
    telegram-desktop
    alacritty
    nixfmt
    hysteria
    (pkgs.writeShellScriptBin "opencode" ''
      set -euo pipefail

      export HTTP_PROXY="http://127.0.0.1:18081"
      export HTTPS_PROXY="$HTTP_PROXY"

      env HTTP_PROXY="http://127.0.0.1:18081" HTTPS_PROXY="http://127.0.0.1:18081" \
        ${pkgs.opencode}/bin/opencode "$@"
    '')
  ];

  programs.rclone = {
    enable = true;

    remotes.onedrive = {
      config = {
        type = "onedrive";
      };

      mounts."" = {
        enable = true;
        mountPoint = "${config.home.homeDirectory}/OneDrive";

        options = {
          config = "${config.xdg.configHome}/rclone/rclone.conf";
          "dir-cache-time" = "96h";
          "drive-chunk-size" = "32M";
          timeout = "1h";
          "vfs-cache-mode" = "full";
          "vfs-cache-max-age" = "999999h";
          "vfs-cache-max-size" = "1G";
        };
      };
    };
  };

  systemd.user.services.rclone-config.Service.ExecStart = lib.mkForce "${pkgs.coreutils}/bin/true";

  home.stateVersion = "25.11";
}
