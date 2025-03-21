{ inputs, outputs, lib, config, pkgs, ... }:

{
  imports = [
    # ../../nixos/security
    # ../../nixos/services
    # ../../nixos/users
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
    ];
    config = { allowUnfree = true; };
  };

  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix.registry = (lib.mapAttrs (_: flake: { inherit flake; }))
    ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  environment.etc = lib.mapAttrs' (name: value: {
    name = "nix/path/${name}";
    value.source = value.flake;
  }) config.nix.registry;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    persistent = true;
    options = "--delete-older-than 30d";
  };

  nix.optimise.automatic = true;

  nix.extraOptions = ''
    keep-derivations = true
    keep-outputs = true
    min-free = ${toString (100 * 1024 * 1024)} # 100MiB
    max-free = ${toString (1024 * 1024 * 1024)} # 1GiB
  '';

  nix.settings = {
    auto-optimise-store = true;
    experimental-features = "nix-command flakes";
    sandbox = true;

    substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos.org/"
    ];

    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages =
    with pkgs; [
      arion
      bind
      binutils
      file
      fzf
      git
      gnupg
      gotop
      htop
      hwinfo
      lsof
      neovim
      nmap
      mkpasswd
      p7zip
      pciutils
      ripgrep
      rsync
      trashy
      tree
      unrar
      unzip
      usbutils
      vim
      w3m
      wget
      zip
    ];

  programs._1password.enable = true;
  programs.adb.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.ssh.startAgent = false;
  programs.zsh.enable = true;

  virtualisation = {
    docker = {
      enable = true;
      autoPrune.enable = true;
    };
    podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    libvirtd.enable = true;
    virtualbox = {
      host.enable = true;
      host.addNetworkInterface = true;
    };
  };

  system.autoUpgrade.enable = false;
}
