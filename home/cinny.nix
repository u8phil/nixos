{ pkgs, ... }:
let
  proxy = "socks5://127.0.0.1:1080";
  noProxy = "localhost,127.0.0.1,::1";

  # Tauri/WebKitGTK app: route via env vars; bypass proxy for its local frontend server.
  cinny = pkgs.symlinkJoin {
    name = "cinny-desktop-proxied";
    paths = [ pkgs.cinny-desktop ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/cinny \
        --set-default http_proxy ${proxy} \
        --set-default HTTP_PROXY ${proxy} \
        --set-default https_proxy ${proxy} \
        --set-default HTTPS_PROXY ${proxy} \
        --set-default all_proxy ${proxy} \
        --set-default ALL_PROXY ${proxy} \
        --set-default no_proxy ${noProxy} \
        --set-default NO_PROXY ${noProxy}
    '';
  };
in
{
  home.packages = [ cinny ];
}
