{ ... }:
{
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    extraConfig.pipewire."10-audio-rates" = {
      "context.properties" = {
        "default.clock.rate" = 192000;
        "default.clock.allowed-rates" = [
          44100
          48000
          88200
          96000
          176400
          192000
          352800
          384000
          705600
          768000
        ];
      };
    };

    wireplumber.extraConfig."20-usb-audio-rates" = {
      "monitor.alsa.rules" = [
        {
          matches = [
            {
              "device.bus" = "usb";
              "media.class" = "Audio/Sink";
            }
          ];
          actions = {
            "update-props" = {
              "audio.rate" = 192000;
              "audio.allowed-rates" = [
                44100
                48000
                88200
                96000
                176400
                192000
                352800
                384000
                705600
                768000
              ];
            };
          };
        }
      ];
    };
  };
}
