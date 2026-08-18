{ config, ... }:
{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  hardware.bluetooth.settings = {
    General = {
      Experimental = true; # show battery

      ControllerMode = "dual";
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
