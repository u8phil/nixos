{ pkgs, ... }:
let
  # Nixpkgs' compiler driver adapted to link with Wild
  wildCc = (pkgs.useWildLinker pkgs.stdenv).cc;
in
{
  home.packages = [
    # The default profile already includes cargo, clippy and rustfmt;
    # the extensions add standard library sources and the language server.
    (pkgs.rust-bin.stable.latest.default.override {
      extensions = [
        "rust-src"
        "rust-analyzer"
      ];
    })
  ];

  # cargo itself comes from rust-overlay above, so only manage the config file.
  programs.cargo = {
    enable = true;
    package = null;
    settings.target."x86_64-unknown-linux-gnu".linker = "${wildCc}/bin/cc";
  };

  # bindgen discovery of libclang
  home.sessionVariables.LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
}
