{ pkgs, ... }:
let
  weeklyTag = "weekly-2026.03.18";

  freecad = pkgs.freecad.overrideAttrs (old: {
    version = "1.2.0dev+${weeklyTag}";

    src = pkgs.fetchFromGitHub {
      owner = "FreeCAD";
      repo = "FreeCAD";
      rev = weeklyTag;
      hash = "sha256-/KFZOS0Ge7xo2TWXX3iXfsZvjTBPS3Z5/5SwwgL5GVo=";
      fetchSubmodules = true;
    };

    # The Nix PYTHONPATH patch is still required on the weekly build.
    patches = pkgs.lib.take 1 old.patches;

    # Upstream now resolves `gmsh` from PATH itself.
    postPatch = "";
  });
in
{
  home.packages = [
    # freecad
  ];
}
