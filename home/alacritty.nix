{ pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      terminal = {
        shell.program = "${pkgs.fish}/bin/fish";
        osc52 = "CopyPaste";
      };

      window = {
        blur = true;
        opacity = 0.5;
      };

      font = {
        size = 10.0;
        normal = {
          family = "FiraCode Nerd Font";
          style = "Regular";
        };
      };
    };
  };
}
