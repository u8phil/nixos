{ pkgs, ... }:
let
  freecad = pkgs.symlinkJoin {
    name = "freecad-wrapped";
    paths = [ pkgs.freecad ];
    nativeBuildInputs = [ pkgs.makeWrapper ];

    postBuild = ''
      rm -f $out/bin/FreeCAD $out/bin/freecad

      makeWrapper ${pkgs.freecad}/bin/FreeCAD $out/bin/FreeCAD \
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
