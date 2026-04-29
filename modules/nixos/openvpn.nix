{
  config,
  pkgs,
  ...
}:
{
  programs.openvpn3 = {
    enable = true;
    netcfg.settings.systemd_resolved = true;
  };

  sops.secrets = {
    "job/username" = {
      owner = "openvpn";
      group = "openvpn";
      mode = "0400";
      path = "/run/secrets/job/username";
    };

    "job/host" = {
      owner = "openvpn";
      group = "openvpn";
      mode = "0400";
      path = "/run/secrets/job/host";
    };

    "job/auth" = {
      owner = "openvpn";
      group = "openvpn";
      mode = "0400";
      path = "/run/secrets/job/auth";
    };

    "job/ca" = {
      owner = "openvpn";
      group = "openvpn";
      mode = "0400";
      path = "/run/secrets/job/ca";
    };

    "job/cert" = {
      owner = "openvpn";
      group = "openvpn";
      mode = "0400";
      path = "/run/secrets/job/cert";
    };

    "job/key" = {
      owner = "openvpn";
      group = "openvpn";
      mode = "0400";
      path = "/run/secrets/job/key";
    };

    "job/tls-crypt" = {
      owner = "openvpn";
      group = "openvpn";
      mode = "0400";
      path = "/run/secrets/job/tls-crypt";
    };
  };

  sops.templates."openvpn-work-ovpn" = {
    owner = "openvpn";
    group = "openvpn";
    mode = "0400";

    content = ''
      setenv opt PROFILE ${config.sops.placeholder."job/username"}@gate.${
        config.sops.placeholder."job/host"
      }
      setenv opt USERNAME ${config.sops.placeholder."job/username"}
      auth-user-pass /run/secrets/job/auth

      ca /run/secrets/job/ca
      cert /run/secrets/job/cert
      cipher AES-256-CBC
      client
      dev tun
      dev-type tun
      key /run/secrets/job/key

      nobind
      port 1196
      proto udp
      push-peer-info
      remote gate.${config.sops.placeholder."job/host"}
      remote-cert-tls server
      reneg-sec 604800
      tls-crypt /run/secrets/job/tls-crypt

      tls-version-min 1.2
      tun-mtu 1420
      verb 3
    '';
  };

  systemd.services.openvpn3-import-work = {
    description = "Import OpenVPN3 profile: work";
    wantedBy = [ "multi-user.target" ];
    after = [ "sops-nix.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      ${pkgs.openvpn3}/bin/openvpn3 config-manage --config work --exists --quiet && \
        ${pkgs.openvpn3}/bin/openvpn3 config-remove --config work --force || true

      ${pkgs.openvpn3}/bin/openvpn3 config-import \
        --persistent \
        --name work \
        --config ${config.sops.templates."openvpn-work-ovpn".path}
    '';
  };

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "vc" ''
      set -euo pipefail

      if sudo ${pkgs.openvpn3}/bin/openvpn3 sessions-list | ${pkgs.gnugrep}/bin/grep -Eq "Config(uration)? name: +work"; then
        echo "work VPN is already connected"
        exit 0
      fi

      sudo ${pkgs.openvpn3}/bin/openvpn3 session-manage --cleanup || true
      exec sudo ${pkgs.openvpn3}/bin/openvpn3 session-start --config work
    '')

    (pkgs.writeShellScriptBin "vd" ''
      set -euo pipefail

      if ! sudo ${pkgs.openvpn3}/bin/openvpn3 sessions-list | ${pkgs.gnugrep}/bin/grep -Eq "Config(uration)? name: +work"; then
        echo "work VPN is not connected"
        exit 0
      fi

      sudo ${pkgs.openvpn3}/bin/openvpn3 session-manage --config work --disconnect || true
      exec sudo ${pkgs.openvpn3}/bin/openvpn3 session-manage --cleanup
    '')
  ];
}
