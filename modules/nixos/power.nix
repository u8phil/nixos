{ config, ... }:

let
  resumeDevice =
    if config.swapDevices == [ ] then
      ""
    else
      let
        swapDevice = builtins.head config.swapDevices;
      in
      if swapDevice ? device then swapDevice.device else "/dev/disk/by-label/${swapDevice.label}";
in

{
  assertions = [
    {
      assertion = config.swapDevices != [ ];
      message = "Hibernate requires at least one configured swap device.";
    }
  ];

  boot = {
    kernelParams = [ "zswap.enabled=1" ];
    inherit resumeDevice;
  };

  services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";
  systemd.sleep.settings.Sleep.HibernateDelaySec = "3min";
}
