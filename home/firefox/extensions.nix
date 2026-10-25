{
  config,
  lib,
  ...
}:
let
  addons = import ./addons.nix;
  profilePath = config.programs.librewolf.profiles.default.path;
  seededExtensions = lib.filter (extension: (extension.initialSettings or { }) != { }) (
    builtins.attrValues addons.extensions
  );

  mkExtensionSetting = extension: {
    name = extension.id;
    value = {
      installation_mode = "normal_installed";
      install_url =
        extension.install_url
          or "https://addons.mozilla.org/firefox/downloads/latest/${extension.slug}/latest.xpi";
    }
    // lib.optionalAttrs (extension.private_browsing or false) {
      private_browsing = true;
    };
  };
in
{
  programs.librewolf.policies.ExtensionSettings = {
    # AdNauseam is retained instead of LibreWolf's default uBlock Origin.
    "uBlock0@raymondhill.net".installation_mode = "blocked";
  }
  // builtins.listToAttrs (map mkExtensionSetting (builtins.attrValues addons.extensions));

  # New installs skip legacy migration; retry this add-on on each startup.
  # The first restart imports the seed only if its IDB is still empty.
  # Firefox leaves any already-populated IDB untouched, preserving user changes.
  programs.librewolf.profiles.default.settings = builtins.listToAttrs (
    map (extension: {
      name = "extensions.webextensions.ExtensionStorageIDB.migrated.${extension.id}";
      value = false;
    }) seededExtensions
  );

  # Firefox imports this storage.js once into ONLY this add-on's IndexedDB
  # storage (native JSON migration). A non-empty IDB is intentionally
  # not overwritten. Do NOT use profiles.extensions.settings: it toggles the
  # storage backend globally. Firefox may rename the seed to .migrated; HM may
  # recreate it later, but a non-empty IDB prevents re-importing the seed.
  home.file = builtins.listToAttrs (
    map (extension: {
      name = ".librewolf/${profilePath}/browser-extension-data/${extension.id}/storage.js";
      value.text = builtins.toJSON extension.initialSettings;
    }) seededExtensions
  );
}
