{ pkgs, ... }:
{
  programs.mpv = {
    enable = true;
    package = pkgs.mpv.override {
      youtubeSupport = false;
    };
    bindings = {
      "H" = "cycle audio";
      "Alt+9" = "add sub-scale -0.1";
      "Alt+0" = "add sub-scale +0.1";
    };
  };
}
