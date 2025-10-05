{ inputs, outputs, lib, config, pkgs, ... }:

let
  megabyte = 1024 * 1024;

in
{
  # Make flakes accessible in the filesystem
  environment.etc = lib.mapAttrs' (name: value: {
    name = "nix/path/${name}";
    value.source = value.flake;
  }) config.nix.registry;

  nix.extraOptions = ''
    keep-derivations = true
    keep-outputs = true
    min-free = ${toString (100 * megabyte)} # 100MiB
    max-free = ${toString (1024 * megabyte)} # 1GiB
  '';

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  nix.optimise.automatic = true;

  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix.registry = (lib.mapAttrs (_: flake: { inherit flake; }))
    ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  nix.settings = {
    auto-optimise-store = true;
    download-buffer-size = (50 * megabyte);
    experimental-features = "nix-command flakes";
    sandbox = true;
  };

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = { allowUnfree = true; };
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
