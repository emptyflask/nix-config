{ den, inputs, ... }:
let
  outputs = {
    nixosModules = import ../../lib/nixos;
    overlays = import ../../overlays { inherit inputs; };
    homeManagerModules = import ../../lib/home-manager;
  };
in
{
  den.hosts.aarch64-linux.newton = {
    # No users - home-manager is standalone, not embedded in NixOS
    instantiate = { modules, ... }:
      inputs.nixpkgs-unstable.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs outputs; };
        inherit modules;
      };
  };

  den.homes.aarch64-linux."jon@newton" = {
    pkgs = inputs.nixpkgs-unstable.legacyPackages.aarch64-linux;
    instantiate = { pkgs, modules }:
      inputs.home-manager-unstable.lib.homeManagerConfiguration {
        inherit pkgs modules;
        extraSpecialArgs = { inherit inputs outputs; };
      };
  };

  den.aspects.newton = {
    nixos = { inputs, outputs, ... }: {
      imports = [ ../../hosts/newton ];
    };
  };
}
