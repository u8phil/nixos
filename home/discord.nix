{ pkgs, ... }:
{
  # Vesktop registers this at runtime; declare it so the forced, HM-managed
  # mimeapps.list keeps the discord:// handler.
  xdg.mimeApps.associations.added."x-scheme-handler/discord" = "vesktop.desktop";
  xdg.mimeApps.defaultApplications."x-scheme-handler/discord" = "vesktop.desktop";

  programs.vesktop = {
    package =
      (pkgs.extend (
        _: prev: {
          vesktop = prev.vesktop.overrideAttrs (oldAttrs: {
            patches = (oldAttrs.patches or [ ]) ++ [/*
              (builtins.toFile "vesktop-wayland-screenshare.patch" ''
                --- a/src/main/screenShare.ts
                +++ b/src/main/screenShare.ts
                @@ -27,6 +27,23 @@
                     });
                ${" "}
                     session.defaultSession.setDisplayMediaRequestHandler(async (request, callback) => {
                +        if (isWayland) {
                +            // A source returned by desktopCapturer belongs to its portal session and cannot be reused.
                +            const placeholder = { id: "screen:0:0", name: "Entire Screen" } as Electron.DesktopCapturerSource;
                +            const stream = await sendRendererCommand<StreamPick>(IpcCommands.SCREEN_SHARE_PICKER, {
                +                screens: [{ id: placeholder.id, name: placeholder.name, url: "" }],
                +                skipPicker: true
                +            }).catch(e => {
                +                console.error("Error during screenshare picker", e);
                +                return null;
                +            });
                +
                +            if (!stream) return callback({});
                +
                +            callback({ video: placeholder });
                +            return;
                +        }
                +
                         // request full resolution on wayland right away because we always only end up with one result anyway
                         const width = isWayland ? 1920 : 176;
                         const sources = await desktopCapturer
                @@ -47,21 +64,6 @@
                             url: thumbnail.toDataURL()
                         }));
                ${" "}
                -        if (isWayland) {
                -            const video = data[0];
                -            if (video) {
                -                const stream = await sendRendererCommand<StreamPick>(IpcCommands.SCREEN_SHARE_PICKER, {
                -                    screens: [video],
                -                    skipPicker: true
                -                }).catch(() => null);
                -
                -                if (stream === null) return callback({});
                -            }
                -
                -            callback(video ? { video: sources[0] } : {});
                -            return;
                -        }
                -
                         const choice = await sendRendererCommand<StreamPick>(IpcCommands.SCREEN_SHARE_PICKER, {
                             screens: data,
                             skipPicker: false
              '')*/
            ];
            desktopItems =
              let
                proxy = "socks5://127.0.0.1:1080";
              in
              map (
                desktopItem:
                desktopItem.override {
                  desktopName = "Discord";
                  exec = "env http_proxy=${proxy} https_proxy=${proxy} vesktop --proxy-server=\"${proxy}\" %U";
                }
              ) (oldAttrs.desktopItems or [ ]);
          });
        }
      )).vesktop;
    enable = true;
    settings = {
      checkUpdates = false;
      customTitleBar = true;
      disableMinSize = true;
      minimizeToTray = true;
      tray = true;
      splashTheming = true;
      staticTitle = true;
      hardwareAcceleration = true;
      discordBranch = "stable";
      # Avoid non-default VPN/VM interface candidates that can leave voice at DTLS connecting.
      webRTCIPHandlingPolicy = "default_public_and_private_interfaces";
    };
  };
}
