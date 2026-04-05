{ den, inputs, ... }:
let
  outputs = {
    nixosModules = import ../../lib/nixos;
    overlays = import ../../overlays { inherit inputs; };
    homeManagerModules = import ../../lib/home-manager;
  };
in
{
  den.hosts.aarch64-darwin.gaudi = {
    # No users - home-manager is standalone, not embedded in darwin
    instantiate = { modules, ... }:
      inputs.darwin.lib.darwinSystem {
        specialArgs = { inherit inputs outputs; };
        inherit modules;
      };
  };

  den.homes.aarch64-darwin."jon@gaudi" = {
    pkgs = inputs.nixpkgs-unstable.legacyPackages.aarch64-darwin;
    instantiate = { pkgs, modules }:
      inputs.home-manager-unstable.lib.homeManagerConfiguration {
        inherit pkgs modules;
        extraSpecialArgs = { inherit inputs outputs; };
      };
  };

  den.aspects.gaudi = {
    darwin = { inputs, outputs, ... }: {
      imports = [ ../../hosts/gaudi/configuration.nix ];
    };
  };
}
