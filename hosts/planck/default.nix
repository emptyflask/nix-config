{ inputs, outputs, lib, config, pkgs, ... }:

let IP_ADDRESS = "192.168.0.70";
in {
  imports = [
    # ../../nixos/security
    # ../../nixos/services
    ../../nixos/users
  ];

  boot.tmp.useTmpfs = true;

  nixpkgs = {
    overlays = [ outputs.overlays.additions outputs.overlays.modifications ];
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

  networking = {
    hostName = "planck";
    useDHCP = true;
    firewall.enable = true;
    firewall.allowedTCPPorts = [ 22 53 80 ];
    firewall.allowedUDPPorts = [ 53 ];
    interfaces.eth0.ipv4.addresses = [{
      address = IP_ADDRESS;
      prefixLength = 24;
    }];
  };

  nix.settings = {
    auto-optimise-store = true;
    experimental-features = "nix-command flakes";
    sandbox = true;

    substituters =
      [ "https://nix-community.cachix.org" "https://cache.nixos.org/" ];

    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    bind
    binutils
    docker
    file
    git
    gnupg
    gotop
    htop
    hwinfo
    lsof
    nmap
    mkpasswd
    pciutils
    rsync
    tree
    unrar
    unzip
    usbutils
    vim
    wget
  ];

  programs.ssh.startAgent = false;
  programs.zsh.enable = true;

  services.couchdb.enable = true;
  services.docker.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      AllowUsers = [ "jon" ];
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = false;
    };
  };

  virtualisation = {
    oci-containers = {
      backend = "docker";
      containers."pihole" = {
        image = "docker.io/pihole/pihole:2025.06.2";
        autoStart = true;
        ports = [ "53:53/tcp" "53:53/udp" "80:80/tcp" "443:443/tcp" ];
        environment = {
          TZ = "America/Chicago";
          FTLCONF_webserver_api_password = "piholio";
          FTLCONF_dns_listeningMode = "all";
        };
        volumes = [
          "/var/lib/pihole/etc-pihole:/etc/pihole"
          "/var/lib/pihole/etc-dnsmasq.d:/etc/dnsmasq.d"
        ];
        extraOptions = [
          "--cap-add=NET_ADMIN"
          "--cap-add=SYS_TIME"
          "--cap-add=SYS_NICE"
          "--restart=unless-stopped"
        ];
      };
    };
  };

  system.autoUpgrade.enable = false;
}
