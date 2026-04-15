{ config, ... }:
{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # stolen from here # https://www.reddit.com/r/NixOS/comments/1ch5d2p/comment/lkbabax/ and 
  # https://github.com/GGG-KILLER/nixos-configs/blob/94a93b66cf8aea2639c52d21a0206834f152c11c/modules/xbox-controller.nix
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
      experimental = true; # show battery

      MinConnectionInterval = 7;
      MaxConnectionInterval = 9;
      ControllerMode = "dual";
      ConnectionLatency = 0;
      Privacy = "device";
      JustWorksRepairing = "confirm";
      Class = "0x000100";
      FastConnectable = true;
    };
  };

  hardware.xpadneo.enable = true; # Enable the xpadneo driver for Xbox One wireless controllers
  hardware.xpadneo.settings = {
    # disable_deadzones:
    #   0 = enables standard behavior to be compatible with joydev expectations
    #   1 = enables raw passthrough of axis values without dead zones for high-precision use with modern Wine/Proton or other games implementing circular deadzones
    disable_deadzones = 1;
    # disable_shift_mode:
    #   0 = Xbox logo button will be used as shift
    #   1 = will pass through the Xbox logo button as is
    disable_shift_mode = 1;
  };

  boot = {
    extraModulePackages = with config.boot.kernelPackages; [ xpadneo ];
    extraModprobeConfig = ''
      options bluetooth disable_ertm=Y
    '';
    # connect xbox controller
  };

}
