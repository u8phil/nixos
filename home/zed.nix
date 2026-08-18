{ pkgs, ... }:
{
  xdg.mimeApps.defaultApplications = {
    "text/markdown" = "dev.zed.Zed.desktop";
    "text/x-markdown" = "dev.zed.Zed.desktop";
  };

  programs.zed-editor = {
    enable = true;

    extensions = [
      "nix"
      "rust"
      "slint"
      "toml"
    ];

    userSettings = {
      ui_font_family = "FiraCode Nerd Font";
      ui_font_size = 15;
      buffer_font_family = "FiraCode Nerd Font";
      buffer_font_size = 13.0;
      buffer_line_height = "standard";
      text_rendering = "subpixel";

      auto_update = false;
      telemetry = {
        diagnostics = false;
        metrics = false;
      };

      autosave.after_delay.milliseconds = 0;

      languages.Nix.language_servers = [
        "nixd"
        "!nil"
      ];
      agent_servers = {
        claude-acp = {
          type = "registry";
          env.CLAUDE_CODE_EXECUTABLE = "${pkgs.claude-code}/bin/claude";
        };
        OpenCode = {
          command = "opencode";
          args = [ "acp" ];
        };
      };

      load_direnv = "shell_hook";

      lsp.nixd = {
        settings.nixd =
          let
            flakePath = "/home/phil/nixos";
          in
          {
            formatting.command = [ "nixfmt" ];
            nixpkgs.expr = "import (builtins.getFlake \"${flakePath}\").inputs.nixpkgs { }";
            options = {
              nixos.expr = "(builtins.getFlake \"${flakePath}\").nixosConfigurations.nixos.options";
              "home-manager".expr =
                "(builtins.getFlake \"${flakePath}\").nixosConfigurations.nixos.options.home-manager.users.type.getSubOptions []";
            };
          };
      };
      lsp."rust-analyzer".binary = {
        path = "${pkgs.devenv}/bin/devenv";
        arguments = [
          "shell"
          "rust-analyzer"
        ];
      };
    };

    userKeymaps = [
      {
        bindings = {
          "ctrl-q" = null;
        };
      }
      {
        context = "Editor && !menu";
        bindings = {
          "ctrl-q" = "editor::DeleteLine";
        };
      }
    ];
  };
}
