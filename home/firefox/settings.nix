{ ... }:
{
  programs.librewolf.profiles.default.settings = {
    "browser.tabs.splitView.enabled" = false;
    "browser.toolbars.bookmarks.visibility" = "never";
    # Mark the session-restore tip as dismissed, including in new profiles.
    "browser.startup.couldRestoreSession.count" = -1;
    "browser.translations.enable" = false;
    "browser.translations.automaticallyPopup" = false;
    "ui.key.menuAccessKey" = 0;
    "ui.key.menuAccessKeyFocuses" = false;

    "browser.topsites.contile.enabled" = false;
    "browser.urlbar.trending.featureGate" = false;
    "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
    "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = false;
    "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = false;
    "browser.newtabpage.activity-stream.section.highlights.includeVisited" = false;
    "browser.newtabpage.activity-stream.showSponsored" = false;
    "browser.newtabpage.activity-stream.system.showSponsored" = false;
    "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;

    "browser.search.suggest.enabled.private" = false;
    "browser.privatebrowsing.forceMediaMemoryCache" = true;
    "browser.sessionstore.privacy_level" = 1;
    "privacy.resistFingerprinting" = false;
    "network.http.referer.XOriginTrimmingPolicy" = 2;
    "security.csp.reporting.enabled" = false;

    # Explicit History settings: browsing/downloads only, no cleanup on exit.
    "places.history.enabled" = true;
    "browser.formfill.enable" = false;
    "privacy.sanitize.sanitizeOnShutdown" = false;
    "pdfjs.enableScripting" = false;
    "signon.autofillForms" = false;
    "signon.formlessCapture.enabled" = false;
    "dom.disable_window_move_resize" = true;
  };
}
