{
  inputs,
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

  # trust step-ca's root so Caddy's ACME client (and this host) trusts
  # https://ca.planck.lan:8443 when requesting certs for *.newton.lan
  security.pki.certificateFiles = [../../nixos/security/ssl/certs/step-ca-root.pem];

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

  environment.systemPackages = with pkgs; [
    restic
  ];

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/Chicago";

  networking = {
    hostName = "newton";
    extraHosts = ''
      127.0.0.1 newton.lan newton
      # newton's own pihole answers NXDOMAIN for other hosts' *.lan zones
      # (doesn't fall through to the router), so pin step-ca's hostname here
      # for ACME to resolve it reliably
      10.9.8.6 ca.planck.lan
    '';
    useDHCP = false;

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
      allowedTCPPorts = [22 53 80 443 2049 config.services.home-assistant.config.http.server_port];
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

  # Key-only SSH box deployed from kepler; lets `nh --target-host` activate
  # without an interactive sudo prompt.
  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "25.11";

  # nixpkgs-flake.nix auto-registers the build nixpkgs (unstable) as nix.registry.nixpkgs.
  # common.nix also registers all flake inputs including the top-level nixpkgs input.
  # Use mkForce to let the auto-registration win for this host.
  nix.registry.nixpkgs = lib.mkForce {flake = inputs.nixpkgs;};
}
