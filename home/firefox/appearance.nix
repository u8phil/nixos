{ ... }:
{
  programs.librewolf.profiles.default = {
    settings = {
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      "browser.uidensity" = 1;
      "browser.compactmode.show" = true;
      # "layout.css.devPixelsPerPx" = "0.9";
    };

    userContent = ''@-moz-document domain("youtube.com") { ${builtins.readFile ./youtube.css} }'';

    userChrome = builtins.readFile ./userChrome.css;
  };
}
