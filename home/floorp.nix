{
  pkgs,
  ...
}:
let
  twitchAdSolutionsVaftPermalink = "https://raw.githubusercontent.com/pixeltris/TwitchAdSolutions/f8f86706daf90daa534b26bce5b2f01238667d5f/vaft/vaft-ublock-origin.js";
  firefoxClassicLogo = pkgs.fetchurl {
    url = "https://upload.wikimedia.org/wikipedia/commons/8/84/Mozilla_Firefox_3.5_logo.png";
    hash = "sha256-9EOE521nTOFzTkpGf912J9IH4WNUoBqLqdybTwnMzRc=";
  };
  proxyTogglePatchedXpi =
    pkgs.runCommand "proxy-toggle-hysteria-xpi"
      {
        nativeBuildInputs = [
          pkgs.unzip
          pkgs.zip
        ];
        src = pkgs.fetchurl {
          url = "https://addons.mozilla.org/firefox/downloads/file/4652025/proxy_toggle-0.3.xpi";
          hash = "sha256-LeI6u9SNsaB17YtCm5yL8kcnE+CF6mQBALeHM4M9FyI=";
        };
      }
      ''
            mkdir work
            cd work
            unzip "$src"

            substituteInPlace background.js \
              --replace-fail 'const DEFAULT_PROXY_SETTINGS = Object.freeze({
          type: "direct",
          host: "",
          port: 0,
          username: "",
          password: "",
          proxyDNS: false,
        });' 'const DEFAULT_PROXY_SETTINGS = Object.freeze({
          type: "socks",
          host: "127.0.0.1",
          port: 1080,
          username: "",
          password: "",
          proxyDNS: true,
        });'

            substituteInPlace settings.js \
              --replace-fail 'browser.storage.local.get({
            skipLocal: true,
            proxySettings: {
              type: "direct",
              host: "",
              port: 0,
              username: "",
              password: "",
              proxyDNS: false,
            },
            useBlacklist: true,
            useWhitelist: false,
            blacklist: [],
            whitelist: [],
          });' 'browser.storage.local.get({
            skipLocal: true,
            proxySettings: {
              type: "socks",
              host: "127.0.0.1",
              port: 1080,
              username: "",
              password: "",
              proxyDNS: true,
            },
            useBlacklist: true,
            useWhitelist: false,
            blacklist: [],
            whitelist: [],
          });'

            mkdir -p "$out"
            zip -qr "$out/proxy_toggle-hysteria.xpi" .
      '';

  floorpExtensions = [
    {
      id = "keepassxc-browser@keepassxc.org";
      slug = "keepassxc-browser";
    }
    {
      id = "adnauseam@rednoise.org";
      slug = "adnauseam";
    }
    {
      id = "sponsorBlocker@ajay.app";
      slug = "sponsorblock";
    }
    {
      id = "moz-addon-prod@7tv.app";
      slug = "7tv-extension";
    }
    {
      id = "addon@darkreader.org";
      slug = "darkreader";
    }
    {
      id = "{8454caa8-cebc-4486-8b23-9771f187ed6c}";
      slug = "600-sound-volume-privacy";
    }
    {
      id = "{9a3104a2-02c2-464c-b069-82344e5ed4ec}";
      slug = "youtube-no-translation";
    }
    {
      id = "proxytoggle@devpg.net";
      install_url = "file://${proxyTogglePatchedXpi}/proxy_toggle-hysteria.xpi";
    }
  ];

  mkExtensionSetting = extension: {
    name = extension.id;
    value = {
      installation_mode = "normal_installed";
      install_url =
        extension.install_url
          or "https://addons.mozilla.org/firefox/downloads/latest/${extension.slug}/latest.xpi";
    };
  };

  floorpUiCustomizationState = {
    placements = {
      "widget-overflow-fixed-list" = [ ];
      "unified-extensions-area" = [
        "sponsorblocker_ajay_app-browser-action"
        "moz-addon-prod_7tv_app-browser-action"
        "adnauseam_rednoise_org-browser-action"
        "_9a3104a2-02c2-464c-b069-82344e5ed4ec_-browser-action"
      ];
      "nav-bar" = [
        "customizableui-special-spring1"
        "customizableui-special-spring3"
        "vertical-spacer"
        "urlbar-container"
        "unified-extensions-button"
        "proxytoggle_devpg_net-browser-action"
        "_8454caa8-cebc-4486-8b23-9771f187ed6c_-browser-action"
        "addon_darkreader_org-browser-action"
        "keepassxc-browser_keepassxc_org-browser-action"
        "downloads-button"
      ];
      "toolbar-menubar" = [ "menubar-items" ];
      "TabsToolbar" = [
        "tabbrowser-tabs"
        "new-tab-button"
        "alltabs-button"
      ];
      "vertical-tabs" = [ ];
      "PersonalToolbar" = [
        "import-button"
        "personal-bookmarks"
      ];
      "nora-statusbar" = [
        "screenshot-button"
        "fullscreen-button"
        "status-text"
      ];
    };
    seen = [
      "developer-button"
      "profile-manager-button"
      "undo-closed-tab"
      "workspaces-toolbar-button"
      "proxytoggle_devpg_net-browser-action"
      "keepassxc-browser_keepassxc_org-browser-action"
      "adnauseam_rednoise_org-browser-action"
      "_8454caa8-cebc-4486-8b23-9771f187ed6c_-browser-action"
      "addon_darkreader_org-browser-action"
      "_9a3104a2-02c2-464c-b069-82344e5ed4ec_-browser-action"
      "sponsorblocker_ajay_app-browser-action"
      "moz-addon-prod_7tv_app-browser-action"
      "screenshot-button"
    ];
    dirtyAreaCache = [
      "nav-bar"
      "vertical-tabs"
      "nora-statusbar"
      "TabsToolbar"
      "PersonalToolbar"
      "unified-extensions-area"
      "toolbar-menubar"
    ];
    currentVersion = 23;
    newElementCount = 2;
  };

  floorpDesignConfigs = {
    uiCustomization.special.hideForwardBackwardButton = true;
    uiCustomization.qrCode.disableButton = true;
  };

  youtubeCss = ''
    .style-scope.ytd-rich-grid-renderer {
        --ytd-rich-grid-items-per-row: 5;
    }

    ytd-rich-item-renderer[rendered-from-rich-grid][is-in-first-column] {
        margin-left: calc(var(--ytd-rich-grid-item-margin)/2);
    }

    .yt-lockup-metadata-view-model--standard.yt-lockup-metadata-view-model--rich-grid-legacy-typography .yt-lockup-metadata-view-model__title {
        font-size: 1.4rem;
    }

    #header.ytd-rich-grid-renderer {
        display: none;
    }

    #frosted-glass.with-chipbar.ytd-app {
        height: unset;
    }

    #voice-search-button.ytd-masthead {
        display: none;
    }

    #country-code {
        font-size: 0;
    }

    #country-code::before {
        content: 'ZALUPA';
        font-size: 10px;
    }

    a[title="Shorts"] {
        display: none;
    }

    ytd-guide-section-renderer:nth-child(3),
    ytd-guide-section-renderer:nth-child(4) {
        display: none;
    }

    ytd-rich-section-renderer {
        display: none;
    }

    /* STUPID FUCKING "Includes paid promotion" button on video preview, DIE */
    a[href="https://support.google.com/youtube?p=ppp&nohelpkit=1"] {
        display: none !important;
    }

    /* AI video summary */
    #expandable-metadata > ytd-expandable-metadata-renderer[has-video-summary=""] {
        display: none;
    }
  '';
in
{
  programs.floorp = {
    enable = true;
    package =
      (pkgs.extend (
        _: prev: {
          floorp-bin = prev.floorp-bin.overrideAttrs (oldAttrs: {
            desktopItem = oldAttrs.desktopItem.override {
              desktopName = "Firefox";
              icon = "${firefoxClassicLogo}";
            };
          });
        }
      )).floorp-bin;
    profiles = {
      default = {
        id = 0;
        isDefault = true;
        settings = {
          "floorp.keyboardshortcut.enabled" = true;
          "floorp.workspaces.enabled" = false;
          "floorp.optimized.msbutton.ope" = true;
          "browser.tabs.firefox-view" = false;
          "browser.toolbars.bookmarks.visibility" = "never";
          "ui.key.menuAccessKey" = 0;
          "ui.key.menuAccessKeyFocuses" = false;
          "browser.uiCustomization.state" = builtins.toJSON floorpUiCustomizationState;
          "floorp.design.configs" = builtins.toJSON floorpDesignConfigs;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "floorp.keyboardshortcut.config" =
            let
              alt = {
                alt = true;
                ctrl = false;
                meta = false;
                shift = false;
              };
            in
            builtins.toJSON {
              enabled = true;

              shortcuts = {
                "alt-q-previous-tab" = {
                  modifiers = alt;
                  key = "Q";
                  action = "gecko-show-previous-tab";
                };
                "alt-w-next-tab" = {
                  modifiers = alt;
                  key = "W";
                  action = "gecko-show-next-tab";
                };
                "alt-r-reload-tab" = {
                  modifiers = alt;
                  key = "R";
                  action = "gecko-reload";
                };
                "alt-a-back-page" = {
                  modifiers = alt;
                  key = "A";
                  action = "gecko-back";
                };
                "alt-s-forward-page" = {
                  modifiers = alt;
                  key = "S";
                  action = "gecko-forward";
                };
                "alt-e-new-tab" = {
                  modifiers = alt;
                  key = "E";
                  action = "gecko-open-new-tab";
                };
                "alt-c-close-tab" = {
                  modifiers = alt;
                  key = "C";
                  action = "gecko-close-tab";
                };
              };
            };
        };

        userContent = "@-moz-document domain(\"youtube.com\") { ${youtubeCss} }";

        userChrome = ''
          #nav-bar-overflow-button,
          #back-button,
          #forward-button,
          #reload-button,
          #stop-button,
          #stop-reload-button,
          #sidebar-box,
          #sidebar-splitter,
          #sidebar-button,
          #panel-sidebar-box,
          #panel-sidebar-select-box,
          #panel-sidebar-splitter {
            display: none !important;
          }
        '';
      };
    };
    policies = {
      # https://discourse.nixos.org/t/nixos-firefox-configuration-with-policies-preferences-extensions-search-engines-and-cookie-exceptions/73747
      DisableFirefoxStudies = true;
      DontCheckDefaultBrowser = true;
      UserMessaging = {
        ExtensionRecommendations = false;
        UrlbarInterventions = false;
        SkipOnboarding = true;
        MoreFromMozilla = false;
        FirefoxLabs = true;
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
      DisablePocket = true;
      TranslateEnabled = false;
      NetworkPrediction = false;

      SearchEngines = {
        Remove = [
          "eBay"
          "Bing"
          "Ecosia"
          "Wikipedia"
          "Perplexity"
        ];
        Default = "Google";
      };

      SearchSuggestEnabled = false;
      preferences = {
        "browser.discovery.enabled" = false;
        "app.shield.optoutstudies.enabled" = false;
        "browser.topsites.contile.enabled" = false;
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        "browser.urlbar.trending.featureGate" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.snippets" = false;
        "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
        "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = false;
        "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = false;
        "browser.newtabpage.activity-stream.section.highlights.includeVisited" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.system.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;

        "extensions.pocket.enabled" = false;
        "browser.search.suggest.enabled" = false;
        "browser.search.suggest.enabled.private" = false;
        "browser.urlbar.suggest.searches" = false;
        "browser.privatebrowsing.forceMediaMemoryCache" = true;
        "network.http.referer.XOriginTrimmingPolicy" = 2;
        "security.csp.reporting.enabled" = false;

        "browser.formfill.enable" = false;
        "pdfjs.enableScripting" = false;
        "signon.rememberSignons" = false;
        "signon.autofillForms" = false;
        "signon.formlessCapture.enabled" = false;
        "dom.disable_window_move_resize" = true;
      };

      "3rdparty".Extensions."adnauseam@rednoise.org" = {
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

      ExtensionSettings = {
        "*".installation_mode = "allowed";
      }
      // builtins.listToAttrs (map mkExtensionSetting floorpExtensions);
    };
  };
}
