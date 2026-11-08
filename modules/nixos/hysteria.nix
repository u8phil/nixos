{
  config,
  pkgs,
  ...
}:
{
  sops.secrets = {
    "hysteria/password" = {
      owner = "root";
      group = "root";
      mode = "0400";
    };
    "vpn" = {
      owner = "root";
      group = "root";
      mode = "0400";
    };
  };

  # SOCKS5 on :1080 (Cinny, Vesktop, browser) and HTTP on :18081 for
  # HTTP(S)_PROXY users (opencode, nix-daemon, nix CLI wrapper).
  #
  # The HTTP side used to be Privoxy bridging SOCKS->HTTP, because Hysteria's
  # own HTTP proxy cut plain HTTP transfers off after 10s (Hysteria <= 2.12.2;
  # fixed in 2.12.3, apernet/hysteria 75aa2f3) and uploaded large bodies ~10x
  # slower on 2.7.0. Re-tested side by side on 2.13.0: identical to Privoxy.
  # Kept on separate ports rather than one shared listener (2.9.3 had a data
  # race in the shared-port HTTP/SOCKS5 multiplexer).
  sops.templates.hysteria = {
    name = "hysteria.yaml";
    owner = "root";
    group = "root";
    mode = "0400";
    # Config edits don't change ExecStart, so restart explicitly.
    restartUnits = [ "hysteria.service" ];

    content = ''
      server: "${config.sops.placeholder.vpn}:443"
      auth: |-
        ${config.sops.placeholder."hysteria/password"}
      socks5:
        listen: "127.0.0.1:1080"
      http:
        listen: "127.0.0.1:18081"
      tls:
        sni: "${config.sops.placeholder.vpn}"
        insecure: false
      fastOpen: false
      log:
        level: "warn"
        timestamp: true
    '';
  };

  systemd.services = with config.sops.templates; {
    hysteria = {
      description = "Hysteria SOCKS5 + HTTP proxy";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.hysteria}/bin/hysteria -c ${hysteria.path} client";
        Restart = "on-failure";
        RestartSec = 2;
      };
    };
  };
}
