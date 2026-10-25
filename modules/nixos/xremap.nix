{ ... }:

{
  services.xremap = {
    enable = true;
    serviceMode = "user";
    userName = "phil";
    withKDE = true;

    config.keymap = [
      {
        name = "LibreWolf shortcuts";
        application.only = [ "/(?i)librewolf/" ];
        exact_match = true;
        remap = {
          "Alt-q" = "C-PageUp";
          "Alt-w" = "C-PageDown";
          "Alt-r" = "C-r";
          "Alt-a" = "Alt-Left";
          "Alt-s" = "Alt-Right";
          "Alt-e" = "C-t";
          "Alt-c" = "C-w";
        };
      }
    ];
  };
}
