{ pkgs, ... }:
{
  home.packages = [ pkgs.tinymist ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;

    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        myriad-dreamin.tinymist
        tomoki1207.pdf
      ];

      userSettings = {
        "files.autoSave" = "afterDelay";
        "files.autoSaveDelay" = 0;
        "editor.fontFamily" = "FiraCode Nerd Font";
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";
        "nix.serverSettings" = {
          nixd =
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
      };

      keybindings = [
        {
          key = "ctrl+q";
          command = "-workbench.action.quit";
        }
        {
          key = "ctrl+q";
          command = "editor.action.deleteLines";
          when = "editorTextFocus && !editorReadonly";
        }
      ];
    };
  };
}
