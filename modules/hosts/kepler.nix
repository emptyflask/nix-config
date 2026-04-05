{ den, inputs, ... }:
let
  outputs = {
    nixosModules = import ../../lib/nixos;
    overlays = import ../../overlays { inherit inputs; };
    homeManagerModules = import ../../lib/home-manager;
  };
in
{
  den.hosts.x86_64-linux.kepler = {
    users.jon = { };
    instantiate = { modules, ... }:
      inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs outputs; };
        inherit modules;
      };
  };

  den.homes.x86_64-linux."jon@kepler" = {
    instantiate = { pkgs, modules }:
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs modules;
        extraSpecialArgs = { inherit inputs outputs; self = inputs.self; };
      };
  };

  den.aspects.kepler = {
    nixos = { inputs, outputs, ... }: {
      imports = [
        inputs.agenix.nixosModules.default
        ../../hosts/kepler
      ];
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = { inherit inputs outputs; self = inputs.self; };
      };
    };
  };
}
