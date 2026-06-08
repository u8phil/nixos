{
  cocoindex-code,
  lib,
  pkgs,
  pyproject-build-systems,
  pyproject-nix,
  uv2nix,
}:

let
  pyproject = builtins.fromTOML (builtins.readFile "${cocoindex-code}/pyproject.toml");
  python = pkgs.python312;
  workspace = uv2nix.lib.workspace.loadWorkspace {
    workspaceRoot = cocoindex-code;
  };

  # Default deps use cocoindex[litellm] (API-based embeddings): no PyTorch, no
  # CUDA, no source compilation. The `full` extra would pull
  # cocoindex[sentence-transformers] for local embeddings (PyTorch + triton),
  # which is intentionally avoided here.
  dependencies = {
    cocoindex-code = [ ];
  };

  pyprojectOverlay = workspace.mkPyprojectOverlay {
    sourcePreference = "wheel";
    inherit dependencies;
  };

  pythonSet = (pkgs.callPackage pyproject-nix.build.packages { inherit python; }).overrideScope (
    lib.composeManyExtensions [
      pyproject-build-systems.overlays.default
      pyprojectOverlay
    ]
  );

  env = pythonSet.mkVirtualEnv "ccc-env" dependencies;
in
pkgs.stdenv.mkDerivation {
  pname = "ccc";
  version = pyproject.project.version or "0.2.33";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    ln -s ${env}/bin/ccc $out/bin/ccc
    ln -s ${env}/bin/cocoindex-code $out/bin/cocoindex-code

    runHook postInstall
  '';

  passthru = {
    pythonEnv = env;
  };

  meta = {
    description = "CocoIndex Code semantic code search CLI and MCP server";
    homepage = "https://github.com/cocoindex-io/cocoindex-code";
    license = lib.licenses.asl20;
    mainProgram = "ccc";
  };
}
