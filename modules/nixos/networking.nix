{ ... }:

{
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "systemd-resolved";
  networking.networkmanager.wifi.powersave = true;
  systemd.services."NetworkManager-wait-online".enable = false;
  services.resolved.enable = true;

  networking.firewall.allowedTCPPorts = [ 8000 8443 ];
}
