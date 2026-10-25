{ ... }:
{
  programs.librewolf.profiles.default = {
    settings = {
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      "browser.uidensity" = 1;
      "browser.compactmode.show" = true;
      "layout.css.devPixelsPerPx" = "0.9";
      # Website appearance: 0 = Dark, 1 = Light, 2 = System
      "layout.css.prefers-color-scheme.content-override" = 0;
    };

    userContent = ''@-moz-document domain("youtube.com") { ${builtins.readFile ./youtube.css} }'';

    userChrome = builtins.readFile ./userChrome.css;
  };
}
