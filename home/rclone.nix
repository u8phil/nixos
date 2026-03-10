{ config, lib, pkgs, ... }:
{
  programs.rclone = {
    enable = true;

    remotes.onedrive = {
      config.type = "onedrive";

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
}