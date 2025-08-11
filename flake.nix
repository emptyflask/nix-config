{
  description = "Jon's nix configuration";

  inputs = {
    # Core
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    lix-module = {
      url =
        "https://git.lix.systems/lix-project/nixos-module/archive/2.93.3-1.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Apple
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixos-apple-silicon = {
      url = "github:tpwrules/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Raspberry Pi
    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-raspberrypi = {
      url = "github:nvmd/nixos-raspberrypi/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Tools
    nur = {
      url = "github:nix-community/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yazi.url = "github:sxyazi/yazi";

    # Neovim plugins
    conform-nvim = {
      url = "github:stevearc/conform.nvim?ref=v9.0.0";
      flake = false;
    };
    nvim-lsp-selection-range = {
      url = "github:camilledejoye/nvim-lsp-selection-range";
      flake = false;
    };
    ruby-code-actions = {
      url = "github:semanticart/ruby-code-actions.nvim";
      flake = false;
    };
    supermaven-nvim = {
      url = "github:supermaven-inc/supermaven-nvim";
      flake = false;
    };
    ts-node-action = {
      url = "github:ckolkey/ts-node-action";
      flake = false;
    };
  };
  nixConfig = {
    extra-substituters =
      [ "https://nixos-raspberrypi.cachix.org" "https://yazi.cachix.org" ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
      "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k="
    ];
  };

  outputs = { self, nixpkgs, home-manager, lix-module, nixos-raspberrypi, agenix
    , ... }@inputs:
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
            agenix.nixosModules.default
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

        planck = nixos-raspberrypi.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { inherit inputs outputs; };
          modules = [
            nixos-raspberrypi.nixosModules.raspberry-pi-4.base
            # nixos-raspberrypi.nixosModules.raspberry-pi-4.display-vc4
            # nixos-raspberrypi.nixosModules.raspberry-pi-4.bluetooth
            ./hosts/planck/default.nix
            # lix-module.nixosModules.default
          ];
        };
      };

      # Standalone home-manager configuration entrypoint
      # Available through 'home-manager --flake .#jon@kepler'
      homeConfigurations = {
        "jon@gaudi" =
          inputs.home-manager-unstable.lib.homeManagerConfiguration {
            pkgs = inputs.nixpkgs-unstable.legacyPackages.aarch64-darwin;
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
