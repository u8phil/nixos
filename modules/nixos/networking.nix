{ ... }:

{
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "systemd-resolved";
  systemd.services."NetworkManager-wait-online".enable = false;
  services.resolved.enable = true;
}
