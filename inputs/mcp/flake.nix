{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    serena = {
      url = "github:oraios/serena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: inputs;
}
