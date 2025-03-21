{
  description = "Jon's nix configuration";

  inputs = {
    darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # hardware.url = "github:nixos/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    lix-module = {
      url =
        "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-apple-silicon = {
      url = "github:tpwrules/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nur.url = "github:nix-community/nur";

    yazi.url = "github:sxyazi/yazi";
  };

  outputs = { self, nixpkgs, home-manager, lix-module, ... }@inputs:
    let
      inherit (self) outputs;
      # Supported systems for your flake packages, shell, etc.
      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      # This is a function that generates an attribute by calling a function you
      # pass to it, with each system as an argument
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      # Your custom packages
      # Accessible through 'nix build', 'nix shell', etc
      packages =
        forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
      # Formatter for your nix files, available through 'nix fmt'
      # Other options beside 'alejandra' include 'nixpkgs-fmt'
      formatter =
        forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

      # Your custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };
      # Reusable nixos modules you might want to export
      # These are usually stuff you would upstream into nixpkgs
      nixosModules = import ./modules/nixos;
      # Reusable home-manager modules you might want to export
      # These are usually stuff you would upstream into home-manager
      homeManagerModules = import ./modules/home-manager;

      darwinConfigurations = {
        gaudi = inputs.darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [ ./hosts/gaudi/configuration.nix ];
          specialArgs = { inherit inputs outputs; };
        };
      };

      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#kepler'
      nixosConfigurations = {
        kepler = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./hosts/kepler/configuration.nix
            lix-module.nixosModules.default
          ];
        };

        newton = inputs.nixpkgs-unstable.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { inherit inputs outputs; };
          pkgs = inputs.nixpkgs-unstable.legacyPackages.aarch64-linux;
          modules = [
            ./hosts/newton/configuration.nix
            lix-module.nixosModules.default
          ];
        };
      };

      # Standalone home-manager configuration entrypoint
      # Available through 'home-manager --flake .#jon@kepler'
      homeConfigurations = {
        "jon@gaudi" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/gaudi/home.nix ];
        };

        "jon@kepler" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/kepler/home.nix ];
        };

        "jon@newton" =
          inputs.home-manager-unstable.lib.homeManagerConfiguration {
            pkgs = inputs.nixpkgs-unstable.legacyPackages.aarch64-linux;
            extraSpecialArgs = { inherit inputs outputs; };
            modules = [ ./hosts/newton/home.nix ];
          };
      };
    };
}
