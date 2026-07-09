{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../nixos/users
    ../common.nix
    ./services
    ./power.nix
  ];

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        configurationLimit = 32;
        consoleMode = "max";
      };
    };
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/Chicago";

  networking = {
    hostName = "newton";
    useDHCP = false;

    # TODO: confirm interface name on machine with `ip link`
    interfaces.enp2s0f0.ipv4.addresses = [
      {
        address = "10.9.8.10";
        prefixLength = 24;
      }
    ];
    defaultGateway = "10.9.8.1";

    # Point at ourselves first (Pi-hole), fallback to Cloudflare
    nameservers = ["127.0.0.1" "1.1.1.1"];

    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [22 53 80 2049];
      allowedUDPPorts = [53 2049];
    };
  };

  programs = {
    command-not-found.enable = false;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    nh = {
      enable = true;
      flake = "/home/jon/dev/nix-config";
    };
    ssh.startAgent = false;
    zsh.enable = true;
  };

  system.stateVersion = "25.11";

  # nixpkgs-flake.nix auto-registers the build nixpkgs (unstable) as nix.registry.nixpkgs.
  # common.nix also registers all flake inputs including the stable nixpkgs input.
  # Use mkForce to let the auto-registration win for this host.
  nix.registry.nixpkgs = lib.mkForce {flake = inputs.nixpkgs-unstable;};
}
