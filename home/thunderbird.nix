{ config, inputs, ... }:
let
  # Addresses come from the private flake (u8phil/private), so they never appear
  # in this public repo. flavor = "gmail.com" auto-fills imap.gmail.com:993 /
  # smtp.gmail.com:465 + TLS, and the Thunderbird module auto-selects OAuth2
  # (authMethod 10) and is_gmail=true because authentication is left unset.
  #
  # The OAuth2 refresh token is still obtained interactively on first connect
  # (one Google sign-in per account) and stored encrypted in the profile -
  # same stateful constraint as rclone; it cannot be provisioned declaratively.
  mkAccount =
    { address, primary }:
    {
      name = address;
      value = {
        inherit address primary;
        realName = "";
        flavor = "gmail.com";
        thunderbird.enable = true;
      };
    };
in
{
  programs.thunderbird = {
    enable = true;
    # Authoritative telemetry kill switch; locks upload + local archiving.
    policies.DisableTelemetry = true;
    profiles.default.isDefault = true;

    settings = {
      # No accounts -> Thunderbird shows the welcome wizard. With the accounts
      # below declared in user.js it loads them directly. These prefs kill the
      # remaining first-run noise and any residual telemetry.
      "mail.shell.checkDefaultClient" = false;
      "mailnews.start_page.enabled" = false;

      # View > Layout > Classic View, and View > Density > Compact.
      "mail.pane_config.dynamic" = 0;
      "mail.uidensity" = 0;

      # New mail notifications through the desktop notification system.
      "mail.biff.show_alert" = true;
      "mail.biff.use_system_alert" = true;
      "mail.biff.alert.show_sender" = true;
      "mail.biff.alert.show_subject" = true;
      "mail.biff.alert.show_preview" = true;
      "mail.biff.play_sound" = false;
      "toolkit.telemetry.enabled" = false;
      "toolkit.telemetry.unified" = false;
      "toolkit.telemetry.archive.enabled" = false;
      "toolkit.telemetry.server" = "";
      "toolkit.telemetry.rejected" = true;
      "toolkit.telemetry.prompted" = 2;
      "toolkit.telemetry.bhrPing.enabled" = false;
      "toolkit.telemetry.firstShutdownPing.enabled" = false;
      "toolkit.telemetry.newProfilePing.enabled" = false;
      "toolkit.telemetry.shutdownPingSender.enabled" = false;
      "toolkit.telemetry.updatePing.enabled" = false;
      "toolkit.telemetry.coverage.opt-out" = true;
      "toolkit.coverage.opt-out" = true;
      "toolkit.coverage.endpoint.base" = "";
      "datareporting.healthreport.uploadEnabled" = false;
      "datareporting.policy.dataSubmissionEnabled" = false;
      "datareporting.usage.uploadEnabled" = false;
      "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
      "breakpad.reportURL" = "";
    };
  };

  accounts.email.accounts = builtins.listToAttrs (
    map mkAccount inputs.private.thunderbird.accounts
  );

  xdg.configFile."autostart/thunderbird.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Thunderbird
    Comment=Start Thunderbird at login
    Exec=${config.programs.thunderbird.finalPackage}/bin/thunderbird
    Terminal=false
    X-KDE-autostart-phase=2
    X-KDE-autostart-after=panel
  '';

  programs.plasma.window-rules = [
    {
      description = "Start Thunderbird minimized";
      match = {
        window-class = {
          value = "thunderbird";
          type = "substring";
          match-whole = false;
        };
        title = {
          # Avoid minimizing compose windows such as "Write: ...".
          value = "^(?!Write:).*Thunderbird.*$";
          type = "regex";
        };
        window-types = [ "normal" ];
      };
      apply.minimize = {
        value = true;
        apply = "initially";
      };
    }
  ];
}
