{ inputs, system }:
final: prev:
let
  master = import inputs.nixpkgs-master {
    inherit system;
    config.allowUnfree = true;
  };
in
{
  claude-code = master.claude-code;

  pkgsi686Linux = prev.pkgsi686Linux.extend (_final': prev': {
    openldap = prev'.openldap.overrideAttrs (_old: {
      doCheck = false;
    });
  });
}
