{
  config,
  lib,
  pkgs,
  ...
}:
let
  mkConfig =
    params:
    lib.strings.toJSON (
      lib.recursiveUpdate params {
        server = "${config.sops.placeholder.server}:443";
        auth = config.sops.placeholder."hysteria/password";

        tls = {
          sni = config.sops.placeholder.server;
          insecure = false;
        };

        fastOpen = false;

        log = {
          level = "warn";
          timestamp = true;
        };
      }
    );

  opencodePrivoxyConfig = pkgs.writeText "opencode-privoxy.conf" ''
    confdir ${pkgs.privoxy}/etc
    logdir /run/opencode-privoxy

    actionsfile match-all.action
    actionsfile default.action
    actionsfile user.action
    filterfile default.filter

    listen-address 127.0.0.1:18081
    toggle 1
    enable-remote-toggle 0
    enable-edit-actions 0

    forward-socks5t / 127.0.0.1:1080 .

    logfile logfile
  '';
in
{
  sops.secrets = {
    "hysteria/password" = {
      owner = "root";
      group = "root";
      mode = "0400";
    };

    "hysteria/server_ip" = {
      owner = "root";
      group = "root";
      mode = "0400";
    };
  };

  sops.templates.hysteria-http = {
    name = "hysteria-http.yaml";
    owner = "root";
    group = "root";
    mode = "0400";

    content = mkConfig {
      http = {
        listen = "127.0.0.1:18080";
      };
    };
  };

  sops.templates.hysteria = {
    name = "hysteria.yaml";
    owner = "root";
    group = "root";
    mode = "0400";

    content = mkConfig {
      tun = {
        name = "hysteria";
        mtu = 1400;
        address = {
          ipv4 = "172.18.0.1/30";
          ipv6 = "2001::ffff:ffff:ffff:fff1/126";
        };
        route = {
          ipv4 = [ "0.0.0.0/0" ];
          ipv6 = [ "2000::/3" ];
          ipv4Exclude = [
            "192.168.0.0/16"
            "127.0.0.0/24"
            "${config.sops.placeholder."hysteria/server_ip"}/32"
          ];
          ipv6Exclude = [ "2a0b:88c0:48::d/128" ];
        };
      };
    };
  };

  sops.templates.hysteria-socks = {
    name = "hysteria-socks.yaml";
    owner = "root";
    group = "root";
    mode = "0400";

    content = mkConfig {
      socks5 = {
        listen = "127.0.0.1:1080";
      };
    };
  };

  systemd.services = with config.sops.templates; {
    hysteria-http = {
      description = "Hysteria HTTP";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.hysteria}/bin/hysteria -c ${hysteria-http.path} client";
        Restart = "on-failure";
        RestartSec = 2;
      };
    };

    hysteria = {
      description = "Hysteria";
      after = [ "network.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.hysteria}/bin/hysteria -c ${hysteria.path} client";
        Restart = "on-failure";
        RestartSec = 2;
      };
    };

    hysteria-socks = {
      description = "Hysteria SOCKS5";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.hysteria}/bin/hysteria -c ${hysteria-socks.path} client";
        Restart = "on-failure";
        RestartSec = 2;
      };
    };

    opencode-socks-http = {
      description = "OpenCode SOCKS to HTTP bridge";
      after = [
        "hysteria-socks.service"
      ];
      wants = [ "hysteria-socks.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        RuntimeDirectory = "opencode-privoxy";
        ExecStart = "${pkgs.privoxy}/bin/privoxy --no-daemon ${opencodePrivoxyConfig}";
        Restart = "on-failure";
        RestartSec = 2;
      };
    };
  };

  networking.firewall.trustedInterfaces = [
    "hysteria"
  ];

  environment.systemPackages = [
    pkgs.privoxy

    (pkgs.writeShellScriptBin "sc" ''
      set -euo pipefail
      exec sudo ${pkgs.systemd}/bin/systemctl start hysteria.service
    '')

    (pkgs.writeShellScriptBin "sd" ''
      set -euo pipefail
      exec sudo ${pkgs.systemd}/bin/systemctl stop hysteria.service
    '')
  ];
}
