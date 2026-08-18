{
  description = "NixOS system with Home Manager and Plasma Manager";

  inputs = {
    self.submodules = true;

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

    oh-my-openagent = {
      url = "github:code-yeongyu/oh-my-openagent";
      flake = false;
    };

    opencode-fusion = {
      url = "github:mihneaptu/opencode-fusion";
      flake = false;
    };


    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    # Private personal data (e.g. email addresses) kept out of this public repo.
    # This is a separate private Git repo checked out at ./private as a Git submodule.
    private = {
      url = ./private;
      flake = true;
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      plasma-manager,
      rust-overlay,
      sops-nix,
      nix-index-database,
      ...
    }:
    let
      system = "x86_64-linux";
      overlays = [
        rust-overlay.overlays.default
        (import ./overlays.nix { inherit inputs system; })
      ];
      pkgs = import nixpkgs {
        inherit system overlays;
      };
    in
    {
      packages.${system} = {
        sops = pkgs.sops;
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
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.backupFileExtension = "bak";

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
