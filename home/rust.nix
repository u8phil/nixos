{ pkgs, ... }:
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
}
