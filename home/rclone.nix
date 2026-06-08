{ config, lib, pkgs, ... }:
let
  remote = "onedrive";
  mountPoint = "${config.home.homeDirectory}/OneDrive";
  # Home Manager names the generated mount unit `rclone-mount:<path>@<remote>`;
  # our remote path is "" so the unit is `rclone-mount:@onedrive`.
  mountUnit = "rclone-mount:@${remote}";
  fusermount = "/run/wrappers/bin/fusermount";
in
{
  programs.rclone = {
    enable = true;

    remotes.${remote} = {
      config.type = "onedrive";

      mounts."" = {
        enable = true;
        inherit mountPoint;

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

  systemd.user.services = {
    rclone-config.Service.ExecStart = lib.mkForce "${pkgs.coreutils}/bin/true";

    # Merges into the mount unit generated above (same name → one unit, not a
    # second service). WiFi-drop recovery: when the network vanishes the FUSE
    # daemon dies and leaves a stale mount — stat() then returns ENOTCONN
    # ("Transport endpoint is not connected"). The module's plain `mkdir -p`
    # ExecStartPre stat()s that path and fails, so every restart aborts before
    # rclone relaunches. Lazy-unmount the stale endpoint first (and on stop),
    # and don't let repeated flaps trip the start-limit and wedge the unit.
    ${mountUnit} = {
      Unit.StartLimitIntervalSec = 0;
      Service = {
        ExecStartPre = lib.mkForce [
          "-${fusermount} -uz ${mountPoint}"
          "${pkgs.coreutils}/bin/mkdir -p ${mountPoint}"
        ];
        ExecStopPost = "-${fusermount} -uz ${mountPoint}";
        RestartSec = "10";
      };
    };
  };
}
