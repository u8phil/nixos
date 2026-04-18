{
  description = "NixOS system with Home Manager and Plasma Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager/trunk";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    betterBlurDx = {
      url = "github:xarblu/kwin-effects-better-blur-dx";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mcp-nixos = {
      url = "github:utensils/mcp-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-grub-themes.url = "github:jeslie0/nixos-grub-themes";

    context-mode.url = "github:mksglu/context-mode";
    context-mode.flake = false;

    caveman.url = "github:JuliusBrussee/caveman";
    caveman.flake = false;

    docs-mcp-server.url = "github:arabold/docs-mcp-server";
    docs-mcp-server.flake = false;
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      mcp-nixos,
      plasma-manager,
      rust-overlay,
      sops-nix,
      context-mode,
      caveman,
      ...
    }:
    let
      system = "x86_64-linux";
      overlays = [
        mcp-nixos.overlays.default
        rust-overlay.overlays.default
      ];
      pkgs = import nixpkgs {
        inherit system overlays;
      };
    in
    {
      packages.${system}.sops = pkgs.sops;

      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.sops
        ];
      };

      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/nixos
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = overlays;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "bak";
            home-manager.extraSpecialArgs = {
              inherit inputs;
              claude-plugins = [ context-mode caveman ];
            };

            home-manager.users.phil = import ./home/default.nix;
            home-manager.sharedModules = [
              sops-nix.homeModules.sops
              plasma-manager.homeModules.plasma-manager
            ];
          }
        ];
      };
    };
}
