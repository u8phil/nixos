{ pkgs, ... }:

{
  # docs-mcp-server in Docker on 127.0.0.1:6820
  virtualisation.oci-containers = {
    backend = "docker";
    containers.docs-mcp-server = {
      image = "ghcr.io/arabold/docs-mcp-server:latest";
      ports = [ "127.0.0.1:6820:6280" ];
      volumes = [
        "docs-mcp-data:/data"
        "docs-mcp-config:/config"
      ];
      cmd = [
        "--protocol"
        "http"
        "--host"
        "0.0.0.0"
        "--port"
        "6280"
      ];
    };
  };

  # Add 127.0.0.2 loopback alias via a simple oneshot service
  systemd.services.loopback-alias-docs = {
    description = "Add 127.0.0.2 loopback alias for docs.local";
    wantedBy = [ "network.target" ];
    before = [ "nginx.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.iproute2}/bin/ip addr add 127.0.0.2/8 dev lo 2>/dev/null || true
    '';
    preStop = ''
      ${pkgs.iproute2}/bin/ip addr del 127.0.0.2/8 dev lo 2>/dev/null || true
    '';
  };

  networking.hosts."127.0.0.2" = [ "docs.local" ];

  # Generate CA + server cert once, before nginx starts
  systemd.services.docs-local-certs = {
    description = "Generate docs.local TLS certificate";
    wantedBy = [ "nginx.service" ];
    before = [ "nginx.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      dir=/var/lib/docs-local
      if [ ! -f "$dir/server.crt" ]; then
        mkdir -p "$dir"
        # CA
        ${pkgs.openssl}/bin/openssl genrsa -out "$dir/ca.key" 4096
        ${pkgs.openssl}/bin/openssl req -x509 -new -nodes \
          -key "$dir/ca.key" -sha256 -days 3650 \
          -subj "/CN=docs.local CA" \
          -out "$dir/ca.crt"
        # Server key + CSR
        ${pkgs.openssl}/bin/openssl genrsa -out "$dir/server.key" 2048
        ${pkgs.openssl}/bin/openssl req -new \
          -key "$dir/server.key" \
          -subj "/CN=docs.local" \
          -out "$dir/server.csr"
        # Sign with SAN
        echo "subjectAltName=DNS:docs.local" > "$dir/ext.cnf"
        ${pkgs.openssl}/bin/openssl x509 -req \
          -in "$dir/server.csr" \
          -CA "$dir/ca.crt" -CAkey "$dir/ca.key" -CAcreateserial \
          -out "$dir/server.crt" \
          -days 3650 -sha256 \
          -extfile "$dir/ext.cnf"
        chown -R nginx:nginx "$dir"
        chmod 640 "$dir"/*.key
      fi
    '';
  };

  # nginx reverse proxy on 127.0.0.2:443 only
  services.nginx = {
    enable = true;
    virtualHosts."docs.local" = {
      onlySSL = true;
      listen = [
        {
          addr = "127.0.0.2";
          port = 443;
          ssl = true;
        }
      ];
      sslCertificate = "/var/lib/docs-local/server.crt";
      sslCertificateKey = "/var/lib/docs-local/server.key";
      locations."/" = {
        proxyPass = "http://127.0.0.1:6820";
        proxyWebsockets = true;
      };
    };
  };

  systemd.services.nginx = {
    after = [
      "docs-local-certs.service"
      "loopback-alias-docs.service"
    ];
    wants = [
      "docs-local-certs.service"
      "loopback-alias-docs.service"
    ];
  };
}
