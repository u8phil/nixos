{ pkgs, ... }:
{
  xdg.mimeApps.defaultApplications = {
    "text/markdown" = "dev.zed.Zed.desktop";
    "text/x-markdown" = "dev.zed.Zed.desktop";
  };

  programs.zed-editor = {
    enable = true;
    mutableUserSettings = false;

    extensions = [
      "nix"
      "rust"
      "slint"
      "toml"
      "jetbrains-themes"
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

      # All Zed AI is off (agent panel, threads sidebar, predictions, inline
      # assistant).
      disable_ai = true;

      # Panel layout: project, git and collaboration panels on the left,
      # outline on the right. The agent docks below only apply if AI is ever
      # turned back on.
      project_panel.dock = "left";
      outline_panel.dock = "right";
      git_panel.dock = "left";
      collaboration_panel.dock = "left";
      agent = {
        dock = "right";
        threads_sidebar.position = "right";
      };

      theme = "JetBrains Islands Dark";

      # Deny language servers by default; opt in per language below.
      enable_language_server = false;
      languages = {
        Rust = {
          enable_language_server = true;
          language_servers = [ "rust-analyzer" ];
        };
        Nix = {
          enable_language_server = true;
          language_servers = [ "nixd" ];
        };
        Slint = {
          enable_language_server = true;
          language_servers = [ "slint" ];
        };
        Python = {
          enable_language_server = true;
          language_servers = [ "ruff" ];
        };
      };
      load_direnv = "shell_hook";

      # Target initialization changes may require `editor: restart language
      # server`. Selecting a profile changes analysis, not Cargo build commands.
      profiles = {
        "Rust Linux x64".settings.lsp."rust-analyzer".initialization_options.cargo.target = "x86_64-unknown-linux-gnu";
        "Rust macOS x64".settings.lsp."rust-analyzer".initialization_options.cargo.target = "x86_64-apple-darwin";
        "Rust Windows x64".settings.lsp."rust-analyzer".initialization_options.cargo.target = "x86_64-pc-windows-gnu";
      };
    };

    userKeymaps = [
      {
        bindings = {
          "ctrl-q" = null;
          "ctrl-alt-t" = "settings_profile_selector::Toggle";
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
