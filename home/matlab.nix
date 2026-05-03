{ pkgs, ... }:
let
  matlabLibs = with pkgs; [
    # --- already present ---
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
    pv

    # --- grpc / protobuf ecosystem ---
    abseil-cpp
    grpc          # libgpr, libgrpc, libaddress_sorting, libupb_*
    re2           # libre2.so
    c-ares        # libcares.so.2

    # --- compression / data formats ---
    libaec        # libaec.so.0 + libsz.so.2 (SZIP compat)
    c-blosc       # libblosc.so.1
    libdeflate    # libdeflate.so.0
    lz4           # liblz4.so.1
    libtiff       # libtiff.so.6
    libpng        # libpng16.so.16
    libsndfile    # libsndfile.so.1

    # --- HDF / scientific data ---
    hdf4          # libdf.so.0, libmfhdf.so.0
    hdf5          # libhdf5.so, libhdf5_hl.so
    sqlite        # libsqlite3.so.3

    # --- image / vision ---
    opencv        # libopencv_*.so.407
    leptonica     # libleptonica.so.5
    tesseract     # libtesseract.so.5
    openvdb       # libopenvdb.so.10.0
    imath         # libImath-3_1.so.29
    openexr       # libIex-3_2, libIlmThread-3_2, libOpenEXR-3_2, libOpenEXRCore-3_2

    # --- geo / projection ---
    geos          # libgeos_c.so.1, libgeos.so.3.12.1
    libgeotiff    # libgeotiff.so.5
    proj          # libproj.so.25

    # --- 3D / rendering ---
    openscenegraph   # libosg*.so.130, libOpenThreads.so.20
    opencascade-occt # libTK*.so.7
    vtk              # libvtk*-9.0.so.1
    halide           # libHalide.so.17

    # --- robotics / SLAM ---
    itk           # libITKCommon-5.3, libitksys-5.3, etc.

    # --- solvers / math ---
    mumps         # libdmumps, libsmumps, libzmumps, libcmumps, libmumps_common
    metis         # libmetis_LP64.so
    gmp           # libgmp.so.3 (version mismatch possible — MATLAB may need .so.3)
    mpfr          # libmpfr.so.1
    tbb           # libtbb.so.12

    # --- constraint programming ---
    gecode        # libgecode*.so.47

    # --- MPI ---
    openmpi       # libmpi.so.12, libmpifort.so.12, libmpicxx.so.12

    # --- media / streaming ---
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base  # libgstapp-1.0.so.0

    # --- database / storage ---
    mariadb-connector-c  # libmariadb.so.3
    mongoc       # libbson-1.0.so.0
    unixODBC             # libodbc.so.2, libodbcinst.so.2
    postgresql.lib       # libpq.so.5

    # --- network / IPC ---
    libssh2       # libssh2.so.1
    curl          # libcurl.so.4
    mosquitto     # libmosquitto.so.1
    libuv         # libuv.so.1
    libfabric     # libfabric.so.1 (OpenFabrics)
    rdma-core     # libibverbs.so.1, librdmacm.so.1
    ucx           # libucp.so.0

    # --- medical imaging ---
    dcmtk         # libdcmdata/net/tls.so.19, libofstd/log/iconv.so.19

    # --- SVN / APR ---
    subversion    # libsvn_*.so.0
    apr           # libapr-1.so.0
    aprutil       # libaprutil-1.so.0
    serf          # libserf-1.so.1.3.0

    # --- XML / XSLT ---
    expat         # libexpat.so.1
    libxslt       # libxslt.so.1
    xercesc       # libxerces-c-3.2.so
    xalanc        # libxalanMsg.so.112
    xmlsec       # libxmlsec1.so.1

    # --- Qt extras ---
    qt5.qtsvg     # libQt5Svg.so.5
    # qt5.qtgamepad   # libQt5Gamepad.so.5 — uncomment if packaged
    # qt5.qtwebkit    # libQt5WebKit.so.5  — removed from nixpkgs; MATLAB may not need

    # --- Poco framework ---
    poco          # libPocoCrypto/Foundation/JSON/Net/Util/XML.so.94

    # --- UHD (USRP) ---
    uhd           # libuhd.so.4.6.0

    # --- misc system ---
    libcap        # libcap.so.2
    numactl       # libnuma.so.1
    icu           # libicudata/i18n/uc.so.74
    libtool       # libltdl.so.7
    utf8proc      # libutf8proc.so.2
    libxcrypt-legacy  # libcrypt.so.1 (libxcrypt provides .so.2 only)
    libpng        # already listed above — keeps it explicit

    # --- xcb extras ---
    libxcb-util    # libxcb-icccm.so.4 libxcb-util.so.1
    libxcb-image        # libxcb-image.so.0
    libxcb-keysyms      # libxcb-keysyms.so.1
    libxcb-render-util # libxcb-render-util.so.0

    # --- Python runtimes (MATLAB Engine) ---
    python3       # add python310/python311 etc. if still in your nixpkgs channel
  ];

  matlab-env = pkgs.buildFHSEnv {
    name = "matlab-env";
    targetPkgs = _: matlabLibs;
    extraBwrapArgs = [
      "--bind /run/user /run/user"
      "--tmpfs /run/lock"
    ];
  };
in
{
  home.packages = [
    matlab-env
  ];
}
