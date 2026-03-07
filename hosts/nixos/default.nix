{ ... }:

{
  imports = [
    ../../hardware-configuration.nix
    ../../modules/nixos
  ];

  networking.hostName = "nixos";
}
