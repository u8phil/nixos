{ pkgs, ... }:
{
  xdg.mimeApps.defaultApplications = {
    "text/markdown" = "dev.zed.Zed.desktop";
    "text/x-markdown" = "dev.zed.Zed.desktop";
  };

  programs.zed-editor = {
    enable = true;
    # Allow UI changes; Nix-defined settings are reapplied on activation.
    mutableUserSettings = true;
    # Keep shortcuts declarative and read-only.
    mutableUserKeymaps = false;

    extensions = [
      "nix"
      "rust"
      "slint"
      "toml"
      "jetbrains-themes"
    ];

    userSettings = {
      ui_font_family = "FiraCode Nerd Font";
      ui_font_size = 14;
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

      # Panel layout: project and git panels on the left,
      # outline on the right. The agent docks below only apply if AI is ever
      # turned back on.
      project_panel = {
        dock = "left";
        # Don't expand the tree to follow the active file.
        auto_reveal_entries = false;
        # Show top-level files/folders directly instead of the project root row.
        hide_root = true;
        # Tighter rows than the default "comfortable".
        entry_spacing = "standard";
      };
      outline_panel.dock = "right";
      git_panel.dock = "left";
      # Hide collaboration and call buttons; commands remain available.
      collaboration_panel = {
        button = false;
        dock = "left";
      };
      show_call_status_icon = false;

      # No account UI in the title bar: sign-in button, user menu, avatar and
      # onboarding banner. The user menu also holds shortcuts to settings and
      # themes; use the command palette for those.
      title_bar = {
        show_sign_in = false;
        show_user_menu = false;
        show_user_picture = false;
        show_onboarding_banner = false;
      };
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
      load_direnv = "disabled";

      # Send an explicit object instead of null. The extension adds "nixd".
      lsp.nixd.settings = { };

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
      {
        context = "Pane";
        bindings = {
          "alt-a" = "pane::GoBack";
          "alt-s" = "pane::GoForward";
          "alt-q" = "pane::ActivatePreviousItem";
          "alt-w" = "pane::ActivateNextItem";
          "alt-c" = "pane::CloseActiveItem";
        };
      }
      {
        context = "Workspace";
        bindings = {
          "alt-e" = "file_finder::Toggle";
        };
      }
    ];
  };
}
