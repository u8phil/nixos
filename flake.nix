{
  description = "NixOS system with Home Manager and Plasma Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager/trunk";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
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

    oh-my-openagent = {
      url = "github:code-yeongyu/oh-my-openagent";
      flake = false;
    };

    cocoindex-code = {
      url = "github:cocoindex-io/cocoindex-code/65125c67ca6f66937cfc7def61217e29152128aa";
      flake = false;
    };

    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
    };

    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
    };

    serena = {
      url = "github:oraios/serena/1931b601efcb0ae1a7c32e0382b3d4085fbaa4a4";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    wild = {
      url = "github:wild-linker/wild";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      # mcp-nixos,
      plasma-manager,
      rust-overlay,
      sops-nix,
      context-mode,
      caveman,
      nix-index-database,
      ...
    }:
    let
      system = "x86_64-linux";
      overlays = [
        rust-overlay.overlays.default
        inputs.wild.overlays.default
        (import ./overlays.nix { inherit inputs system; })
      ];
      pkgs = import nixpkgs {
        inherit system overlays;
      };
      cocoindexCodePackage = pkgs.callPackage ./packages/ccc.nix {
        inherit (inputs)
          pyproject-build-systems
          pyproject-nix
          uv2nix
          ;
        cocoindex-code = inputs.cocoindex-code;
        inherit pkgs;
      };
    in
    {
      packages.${system} = {
        sops = pkgs.sops;
        ccc = cocoindexCodePackage;
      };

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
          nix-index-database.nixosModules.default
          {
            nixpkgs.overlays = overlays;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "bak";
            home-manager.extraSpecialArgs = {
              inherit inputs cocoindexCodePackage;
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
