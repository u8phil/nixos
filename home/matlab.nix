{ pkgs, ... }:
let
  matlabLibs = with pkgs; [
    aspell
    portaudio
    pixman
    harfbuzz
    libxml2
    qt5.qtbase
    libffi
    udev
    coreutils
    alsa-lib
    dpkg
    gcc
    freetype
    glib
    fontconfig
    openssl
    which
    ncurses
    jdk11
    pam
    dbus
    dbus-glib
    pango
    gtk2
    gtk3
    atk
    gdk-pixbuf
    cairo
    ncurses5
    mesa
    libGLU
    zlib
    libglvnd
    libselinux
    gtkmm3
    atkmm
    glibmm
    libsigcxx
    stdenv.cc.cc.lib
    libx11
    libxcursor
    libxrandr
    libxext
    libsm
    libice
    libxdamage
    libxrender
    libxfixes
    libxcomposite
    libxcb
    libxi
    libxscrnsaver
    libxtst
    libxt
    libxft
    libxxf86vm
    libxpm
    libxmu
    nss
    nspr
    cups
    libdrm
    libgbm
    libuuid
    libxkbcommon
    libxau
    libxdmcp
    libxinerama
  ];

  matlab-env = pkgs.buildFHSEnv {
    name = "matlab-env";
    targetPkgs = _: matlabLibs;
    extraBwrapArgs = [
      "--bind /run/user /run/user"
    ];
  };
in
{
  home.packages = [
    matlab-env
  ];
}
