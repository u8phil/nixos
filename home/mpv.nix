{ pkgs, ... }:
{
  programs.mpv = {
    enable = true;
    package = pkgs.mpv.override {
      youtubeSupport = false;
    };
    config = {
      alang = "eng,en-US,en";
    };
    bindings = {
      "h" = "cycle audio";
      "Alt+9" = "add sub-scale -0.1";
      "Alt+0" = "add sub-scale +0.1";
    };
  };
}
