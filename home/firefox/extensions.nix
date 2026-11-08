{ ... }:
let
  addons = import ./addons.nix;

  mkExtensionSetting = extension: {
    name = extension.id;
    value = {
      installation_mode = "normal_installed";
      install_url =
        extension.install_url
          or "https://addons.mozilla.org/firefox/downloads/latest/${extension.slug}/latest.xpi";
      # Deny private windows unless opted in; also revokes manual grants.
      private_browsing = extension.private_browsing or false;
    };
  };
in
{
  programs.librewolf.policies.ExtensionSettings = {
    # "blocked" uninstalls previously installed copies.
    "adnauseam@rednoise.org".installation_mode = "blocked";
    "{DEBA3021-9876-4702-89BA-42D095339A0A}".installation_mode = "blocked";
    "proxytoggle@devpg.net".installation_mode = "blocked";
    # Replaced by the proxied default profile (see default.nix).
    "foxyproxy@eric.h.jung".installation_mode = "blocked";
  }
  // builtins.listToAttrs (map mkExtensionSetting (builtins.attrValues addons.extensions));
}
