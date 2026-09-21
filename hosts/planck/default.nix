{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # ../../nixos/security
    ../../nixos/services/adguardhome.nix
    ./hardware-configuration.nix
    ../../nixos/users
    ../common.nix
    ./samba.nix
    ./services
  ];

  # trust step-ca's own root so Caddy's ACME client trusts
  # https://ca.planck.lan:8443 when requesting certs for *.planck.lan
  security.pki.certificateFiles = [../../nixos/security/ssl/certs/step-ca-root.pem];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.tmp.useTmpfs = true;
  boot.supportedFilesystems = lib.mkForce ["vfat" "btrfs" "tmpfs"];

  nixpkgs = {
    overlays = [outputs.overlays.additions outputs.overlays.modifications];
    config = {allowUnfree = true;};
    hostPlatform = "aarch64-linux";
  };

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  nix.nixPath = ["nixpkgs=${inputs.nixos-raspberrypi.inputs.nixpkgs}"];

  nix.settings.substituters = [
    "https://nix-community.cachix.org"
    "https://cache.nixos.org/"
  ];

  nix.settings.trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];

  # nixpkgs-flake.nix auto-registers the nixpkgs used to build this system
  # (nixos-raspberrypi's own pinned nixpkgs input, since planck is built via
  # nixos-raspberrypi.lib.nixosSystem) as nix.registry.nixpkgs.
  # common.nix also registers all flake inputs including the top-level nixpkgs input.
  # Use mkForce to let the auto-registration win for this host.
  nix.registry.nixpkgs = lib.mkForce {flake = inputs.nixos-raspberrypi.inputs.nixpkgs;};

  networking = {
    hostName = "planck";
    useDHCP = true;
    firewall = let
      dns = 53;
      http = 80;
      https = 443;
      mountd = 20048;
      rpcbind = 111;
      nfs = 2049;
      ntp = 123;
      ssh = 22;
      statd = 4000;
      lockd = 4001;
    in {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [dns http https lockd mountd nfs rpcbind ssh statd];
      allowedUDPPorts = [dns lockd mountd nfs ntp rpcbind statd];
    };
    # Point at our own AdGuard Home first (it has rewrites for kepler.lan,
    # newton.lan, and planck.lan), fallback to Cloudflare. Without this,
    # step-ca's ACME http-01/tls-alpn-01 challenges can't resolve *.lan
    # validation targets: public DNS returns a definitive NXDOMAIN for them,
    # so renewal fails silently until every issued cert has expired.
    nameservers = ["127.0.0.1" "1.1.1.1" "1.0.0.1"];
  };

  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    bind
    binutils
    file
    git
    gnupg
    gotop
    htop
    hwinfo
    libraspberrypi
    lsof
    nmap
    mkpasswd
    pciutils
    raspberrypi-eeprom
    rsync
    tree
    unzip
    usbutils
    vim
    wget
  ];

  programs.ssh.startAgent = false;
  programs.zsh = {
    enable = true;
    # home-manager's zsh module already runs (cached) compinit
    enableCompletion = false;
  };

  # power.ups.enable = true;

  systemd.tmpfiles.rules = [
    "d /var/lib/nodered 0755 root root -"
  ];

  time.timeZone = "America/Chicago";

  virtualisation = {
    oci-containers = {
      backend = "podman";

      containers = {
        dockhand = {
          image = "docker.io/fnsys/dockhand:latest";
          ports = ["127.0.0.1:3300:3000"];
          volumes = [
            "/run/podman/podman.sock:/run/podman/podman.sock"
            "dockhand:/app/data"
          ];
          extraOptions = [
            "--group-add=${toString config.users.groups.podman.gid}"
          ];
        };

        # nodered = {
        #   image = "nodered/node-red:latest";
        #   ports = [ "1880:1880" ];
        #   volumes = [ "/var/lib/nodered:/data" ];
        # };
      };
    };
  };

  # Key-only SSH box deployed from kepler; lets `nh --target-host` activate
  # without an interactive sudo prompt.
  security.sudo.wheelNeedsPassword = false;

  system.autoUpgrade.enable = false;
  system.stateVersion = "25.05";
}
