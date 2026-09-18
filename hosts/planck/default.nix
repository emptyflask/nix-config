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
    # ../../nixos/services
    ./hardware-configuration.nix
    ../../nixos/users
    ../common.nix
    ./samba.nix
    ./services
  ];

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
      allowedTCPPorts = [dns http lockd mountd nfs rpcbind ssh statd];
      allowedUDPPorts = [dns lockd mountd nfs ntp rpcbind statd];
    };
    nameservers = ["1.1.1.1" "1.0.0.1"];
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
    "d /var/lib/pihole/etc-pihole 0755 root root -"
    "d /var/lib/pihole/etc-dnsmasq.d 0755 root root -"
  ];

  time.timeZone = "America/Chicago";

  age.secrets.pihole-env.file = ../../secrets/pihole.env.age;

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

        pihole = {
          image = "pihole/pihole:latest";
          autoStart = true;
          ports = ["53:53/tcp" "53:53/udp" "8080:80/tcp"];
          environment = {
            TZ = "America/Chicago";
            FTLCONF_dns_listeningMode = "all";
            FTLCONF_dns_reply_host_force4 = "true";
            FTLCONF_dns_reply_host_IPv4 = "10.9.8.6";
          };
          environmentFiles = [config.age.secrets.pihole-env.path];
          volumes = [
            "/var/lib/pihole/etc-pihole:/etc/pihole"
            "/var/lib/pihole/etc-dnsmasq.d:/etc/dnsmasq.d"
          ];
          extraOptions = ["--cap-add=NET_ADMIN" "--cap-add=SYS_TIME" "--cap-add=SYS_NICE"];
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
