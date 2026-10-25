{ ... }:
let
  addons = import ./addons.nix;
  twitchAdSolutionsVaftPermalink = "https://raw.githubusercontent.com/pixeltris/TwitchAdSolutions/f8f86706daf90daa534b26bce5b2f01238667d5f/vaft/vaft-ublock-origin.js";
in
{
  programs.librewolf.policies = {
    # https://discourse.nixos.org/t/nixos-firefox-configuration-with-policies-preferences-extensions-search-engines-and-cookie-exceptions/73747
    DisableFirefoxStudies = true;
    DontCheckDefaultBrowser = true;
    UserMessaging = {
      UrlbarInterventions = false;
      SkipOnboarding = true;
      MoreFromMozilla = false;
      FirefoxLabs = false;
    };
    FirefoxSuggest = {
      WebSuggestions = false;
      SponsoredSuggestions = false;
      ImproveSuggest = false;
      Locked = true;
    };

    AutofillAddressEnabled = false;
    AutofillCreditCardEnabled = false;
    OfferToSaveLogins = false;
    PasswordManagerEnabled = false;
    DisableMasterPasswordCreation = true;
    HttpsOnlyMode = "force_enabled";
    SSLVersionMin = "tls1.2";
    PostQuantumKeyAgreementEnabled = true;

    DisableTelemetry = true;
    AIControls.Translations.Value = "blocked";
    NetworkPrediction = false;

    SearchEngines = {
      # LibreWolf does not ship a Google engine for the default to select.
      Add = [
        {
          Name = "Google";
          URLTemplate = "https://www.google.com/search?q={searchTerms}";
          Method = "GET";
        }
      ];
      Remove = [
        "eBay"
        "Bing"
        "Ecosia"
        "Wikipedia"
        "Perplexity"
      ];
      Default = "Google";
      DefaultPrivate = "Google";
    };

    SearchSuggestEnabled = false;

    "3rdparty".Extensions.${addons.extensions.adnauseam.id} = {
      userSettings = [
        [
          "advancedUserEnabled"
          "true"
        ]
      ];
      advancedSettings = [
        [
          "userResourcesLocation"
          twitchAdSolutionsVaftPermalink
        ]
      ];
      toOverwrite.filters = [ "twitch.tv##+js(twitch-videoad)" ];
    };
  };
}
