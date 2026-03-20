{ config, ... }:
{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
      experimental = true; # show battery

      # https://www.reddit.com/r/NixOS/comments/1ch5d2p/comment/lkbabax/
      # for pairing bluetooth controller
      Privacy = "device";
      JustWorksRepairing = "always";
      Class = "0x000100";
      FastConnectable = true;
    };
  };

  hardware.xpadneo.enable = true; # Enable the xpadneo driver for Xbox One wireless controllers
  boot = {
    extraModulePackages = with config.boot.kernelPackages; [ xpadneo ];
    extraModprobeConfig = ''
      options bluetooth disable_ertm=Y
    '';
    # connect xbox controller
  };

}
