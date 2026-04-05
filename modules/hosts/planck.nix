{ den, inputs, ... }:
let
  inherit (inputs) nixos-raspberrypi;
  outputs = {
    nixosModules = import ../../lib/nixos;
    overlays = import ../../overlays { inherit inputs; };
    homeManagerModules = import ../../lib/home-manager;
  };
in
{
  den.hosts.aarch64-linux.planck = {
    users.jon = { };
    instantiate = { modules, ... }:
      nixos-raspberrypi.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs outputs nixos-raspberrypi; };
        inherit modules;
      };
  };

  den.aspects.planck = {
    nixos = { inputs, outputs, nixos-raspberrypi, ... }: {
      imports = [
        nixos-raspberrypi.nixosModules.raspberry-pi-4.base
        ../../hosts/planck
        outputs.nixosModules.local-ca
      ];
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = { inherit inputs; self = inputs.self; };
      };
    };
  };
}
