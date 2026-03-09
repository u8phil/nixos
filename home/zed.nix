{ ... }:
{
  programs.zed-editor = {
    enable = true;
    extensions = [ "nix" ];

    userSettings.autosave.after_delay.milliseconds = 0;
    userSettings.buffer_font_size = 13.5;
    userSettings.buffer_line_height = "standard";
    userSettings.buffer_font_family = "FiraCode Nerd Font";
    userSettings.languages.Nix.language_servers = [
      "nixd"
      "!nil"
    ];
    userSettings.lsp.nixd.settings = {
      nixpkgs.expr = "import (builtins.getFlake \"/etc/nixos\").inputs.nixpkgs { }";
      options.nixos.expr = "(builtins.getFlake \"/etc/nixos\").nixosConfigurations.nixos.options";
      options."home-manager".expr =
        "(builtins.getFlake \"/etc/nixos\").nixosConfigurations.nixos.options.home-manager.users.type.getSubOptions []";
    };

    userKeymaps = [
      {
        context = "Workspace";
        bindings = {
          "ctrl-q" = null;
        };
      }
      {
        context = "Editor";
        bindings = {
          "ctrl-q" = "editor::DeleteLine";
        };
      }
    ];
  };
}
