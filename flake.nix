{
  description = "Jon's nix configuration";

  inputs = {
    # Core
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Apple
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-apple-silicon = {
      url = "github:tpwrules/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Raspberry Pi
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/develop";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # release-26.05, pinned to the Pi's own nixpkgs; used only by planck
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixos-raspberrypi/nixpkgs";
    };

    # Tools
    agenix.url = "github:ryantm/agenix";
    claude-code.url = "github:sadjow/claude-code-nix";
    flatpaks.url = "github:in-a-dil-emma/declarative-flatpak/latest";
    hermes-agent.url = "github:NousResearch/hermes-agent";
    hermes-webui.url = "github:nesquena/hermes-webui";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-anywhere.url = "github:nix-community/nixos-anywhere";
    nur.url = "github:nix-community/nur";
    yazi.url = "github:sxyazi/yazi";

    mcp = {
      url = "path:inputs/mcp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-plugins.url = "path:inputs/neovim-plugins";

    livesync-cli = {
      url = "path:inputs/livesync-cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  nixConfig = {
    extra-substituters = [
      "https://claude-code.cachix.org"
      "https://nixos-raspberrypi.cachix.org"
      "https://yazi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
      "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k="
    ];
  };

  outputs = inputs: import ./outputs.nix inputs;
}
