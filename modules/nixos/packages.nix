{
  lib,
  pkgs,
  ...
}:

let
  bottles = pkgs.bottles.override {
    removeWarningPopup = true;
  };
in
{
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/phil/nixos";
  };

  programs.nix-index-database.comma.enable = true;
  programs.firejail = {
    enable = true;
    wrappedBinaries = {
      bottles = {
        executable = "${bottles}/bin/bottles";
        desktop = "${bottles}/share/applications/com.usebottles.bottles.desktop";
        # Bottles itself uses bubblewrap for the Nix FHS environment; Firejail's
        # default profile blocks that nested namespace setup.
        extraArgs = [ "--noprofile" ];
      };
      bottles-cli = {
        executable = "${bottles}/bin/bottles-cli";
        extraArgs = [ "--noprofile" ];
      };
    };
  };

  services.envfs.enable = true;

  environment.systemPackages =
    (with pkgs; [
      fish
      wget
      btop
      git
      ripgrep
      sops
      file
      (lib.hiPrio pkgs.uutils-coreutils-noprefix)
    ])
    ++ [ bottles ];
}
