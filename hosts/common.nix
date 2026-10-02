{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  mebibyte = 1024 * 1024;
  gibibyte = 1024 * mebibyte;
in {
  # Make flakes accessible in the filesystem
  environment.etc =
    lib.mapAttrs' (name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
    })
    config.nix.registry;

  nix.extraOptions = ''
    keep-derivations = true
    keep-outputs = true
    min-free = ${toString (2 * gibibyte)} # Reserve 2GiB minimum free
    max-free = ${toString (4 * gibibyte)} # Target 4GiB free space after GC
  '';

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];

  nix.optimise.automatic = true;

  nix.package = pkgs.lixPackageSets.stable.lix;

  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix.registry =
    (lib.mapAttrs (_: flake: {inherit flake;}))
    ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  nix.settings =
    {
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];
      sandbox = true;
    }
    # broken-string-escape only exists as a deprecated feature since Lix 2.95;
    # planck is on stable nixpkgs (Lix 2.94) and rejects the unknown name.
    // lib.optionalAttrs (lib.versionAtLeast config.nix.package.version "2.95") {
      extra-deprecated-features = "broken-string-escape";
    };

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications

      # You can also add overlays exported from other flakes:
      inputs.affinity-nix.overlays.default
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {allowUnfree = true;};
  };

  environment.systemPackages = with pkgs; [
    bind
    binutils
    coreutils
    file
    fzf
    git
    gnupg
    gotop
    htop
    hwinfo
    lsof
    nettools
    nmap
    mkpasswd
    openssl
    p7zip
    pciutils
    ripgrep
    rsync
    trashy
    tree
    unzip
    usbutils
    w3m
    wget
    vim
    zip
  ];
}
