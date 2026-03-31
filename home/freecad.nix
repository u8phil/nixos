{ inputs, pkgs, ... }:
let
  freecadBase = inputs.nixpkgs-master.legacyPackages.${pkgs.stdenv.hostPlatform.system}.freecad;

  freecad = pkgs.symlinkJoin {
    name = "freecad-wrapped";
    paths = [ freecadBase ];
    nativeBuildInputs = [ pkgs.makeWrapper ];

    postBuild = ''
      rm -f $out/bin/FreeCAD $out/bin/freecad

      makeWrapper ${freecadBase}/bin/FreeCAD $out/bin/FreeCAD \
        --set QT_QPA_PLATFORM xcb

      ln -s $out/bin/FreeCAD $out/bin/freecad
    '';
  };
in
{
  home.packages = [
    freecad
  ];
}
