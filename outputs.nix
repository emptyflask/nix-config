{
  agenix,
  flatpaks,
  hermes-agent,
  hermes-webui,
  home-manager,
  nixos-raspberrypi,
  nixpkgs,
  self,
  ...
} @ inputs: let
  inherit (self) outputs;

  systems = ["aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux"];
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
  overlays = import ./overlays {inherit inputs;};
  # Reusable nixos modules you might want to export
  # These are usually stuff you would upstream into nixpkgs
  nixosModules = import ./modules/nixos;
  # Reusable home-manager modules you might want to export
  # These are usually stuff you would upstream into home-manager
  homeManagerModules = import ./modules/home-manager;

  darwinConfigurations = {
    gaudi = inputs.darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [./hosts/gaudi/configuration.nix];
      specialArgs = {inherit inputs outputs;};
    };
  };

  # NixOS configuration entrypoint
  # Available through 'nixos-rebuild --flake .#kepler'
  nixosConfigurations = {
    kepler = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs outputs;};
      modules = [
        ./hosts/kepler
        agenix.nixosModules.default
        flatpaks.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.jon = ./hosts/kepler/home.nix;
            extraSpecialArgs = {inherit inputs self;};
            sharedModules = [
              agenix.homeManagerModules.default
              inputs.nix-index-database.homeModules.nix-index
            ];
          };
        }
      ];
    };

    newton = inputs.nixpkgs-unstable.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs outputs;};
      modules = [
        ./hosts/newton
        agenix.nixosModules.default
        hermes-agent.nixosModules.default
        hermes-webui.nixosModules.default
        inputs.livesync-cli.nixosModules.default
        inputs.home-manager-unstable.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.jon = ./hosts/newton/home.nix;
            extraSpecialArgs = {inherit inputs outputs;};
            sharedModules = [
              inputs.nix-index-database.homeModules.nix-index
            ];
          };
        }
      ];
    };

    planck = nixos-raspberrypi.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = {inherit inputs outputs nixos-raspberrypi;};
      modules = [
        agenix.nixosModules.default
        nixos-raspberrypi.nixosModules.raspberry-pi-4.base
        ./hosts/planck
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.jon = ./hosts/planck/home.nix;
            extraSpecialArgs = {inherit inputs self;};
          };
        }
        outputs.nixosModules.local-ca
      ];
    };
  };

  # Standalone home-manager configuration entrypoint
  # Available through 'home-manager --flake .#jon@kepler'
  homeConfigurations = {
    "jon@gaudi" = inputs.home-manager-unstable.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs-unstable.legacyPackages.aarch64-darwin;
      extraSpecialArgs = {inherit inputs outputs;};
      modules = [agenix.homeManagerModules.default ./hosts/gaudi/home.nix];
    };

    "jon@kepler" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = {inherit inputs outputs self;};
      modules = [agenix.homeManagerModules.default ./hosts/kepler/home.nix];
    };
  };
}
