{ ... }:
{
  imports = [
    ./package.nix
    ./extensions.nix
    ./policies.nix
    ./settings.nix
    ./appearance.nix
    ./toolbar.nix
  ];

  programs.librewolf = {
    enable = true;
    profiles.default = {
      id = 0;
      isDefault = true;
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = [ "librewolf.desktop" ];
      "application/xhtml+xml" = [ "librewolf.desktop" ];
      "x-scheme-handler/http" = [ "librewolf.desktop" ];
      "x-scheme-handler/https" = [ "librewolf.desktop" ];
    };
  };
}
