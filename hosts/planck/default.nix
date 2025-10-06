{ inputs, outputs, lib, config, pkgs, ... }:

{
  imports = [
    # ../../nixos/security
    # ../../nixos/services
    ./hardware-configuration.nix
    ../../nixos/users
    ../common.nix
    ./samba.nix
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
  ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.tmp.useTmpfs = true;
  boot.kernelPackages = lib.mkForce pkgs.linuxKernel.packages.linux_rpi4;
  boot.supportedFilesystems = lib.mkForce [ "vfat" "btrfs" "tmpfs" ];

  nixpkgs = {
    overlays = [ outputs.overlays.additions outputs.overlays.modifications ];
    config = { allowUnfree = true; };
    hostPlatform = "aarch64-linux";
  };

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  nix.settings.substituters =
    [ "https://nix-community.cachix.org" "https://cache.nixos.org/" ];

  nix.settings.trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];

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
      allowedTCPPorts = [ dns http lockd mountd nfs rpcbind ssh statd ];
      allowedUDPPorts = [ dns lockd mountd nfs ntp rpcbind statd ];
    };
    nameservers = [ "1.1.1.1" "1.0.0.1" ];
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
  programs.zsh.enable = true;

  # power.ups.enable = true;

  # services.couchdb.enable = true;
  # services.docker.enable = true;

  # services.localCA = {
  #   enable = true;
  #   certFile = "planck.pem";
  #   keyFile = "planck-key.pem";
  #   domains = [ "planck.lan" "pi.hole" "pihole.lan" "node-red.lan" ];
  #   validityDays = 730;
  #   renewBeforeDays = 30;
  # };

  services.chrony = {
    enable = true;
    extraConfig = "allow 10.9.0.0/16";
    servers = [
      "ns.nts.umn.edu"
      "ntp.state.mn.us"
      "time.nist.gov"
      "0.us.pool.ntp.org"
    ];
  };

  services.nfs = {
    server = {
      enable = true;
      exports = ''
        /       10.9.0.0/16(ro,insecure,sync,no_subtree_check,crossmnt,fsid=0)
        /photon 10.9.8.0/24(rw,insecure,sync,no_subtree_check)
        /photon 10.9.0.0/16(ro,insecure,sync,no_subtree_check)
        /squid  10.9.8.0/24(rw,insecure,sync,no_subtree_check)
        /squid  10.9.0.0/16(ro,insecure,sync,no_subtree_check)
      '';
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      AllowUsers = [ "jon" ];
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = false;
    };
  };

  services.rpcbind.enable = true;

  services.traefik = {
    enable = true;
    staticConfigOptions = {
      entryPoints = {
        web = {
          address = ":80";
          asDefault = true;
          # http.redirections.entrypoint = {
          #   to = "websecure";
          #   scheme = "https";
          # };
        };
        websecure = {
          address = ":443";
          asDefault = true;
          http.tls.certResolver = "letsencrypt";
        };
      };
      providers.docker = {
        endpoint = "unix:///run/podman/podman.sock";
        exposedByDefault = false;
      };
      certificatesResolvers.myresolver.acme = {
        email = "jon@emptyflask.net";
        storage = "${config.services.traefik.dataDir}/acme.json";
        httpChallenge.entryPoint = "web";
      };
      # tls.stores.default.defaultCertificate = {
      #   certFile = config.services.localCA.certFilePath;
      #   keyFile  = config.services.localCA.keyFilePath;
      # };
    };

    dynamicConfigOptions = {
      http.routers = {
        pihole = {
          rule = "Host(`pi.hole`) || Host(`pihole.lan`)";
          entryPoints = [ "websecure" ];
          service = "pihole";
          tls.certResolver = "myresolver";
        };
        nodeRed = {
          rule = "Host(`node-red.lan`)";
          entryPoints = [ "websecure" ];
          service = "nodeRed";
          tls.certResolver = "myresolver";
        };
      };

      http.services = {
        pihole.loadBalancer.servers = [{ url = "http://127.0.0.1:8080"; }];
        nodeRed.loadBalancer.servers = [{ url = "http://127.0.0.1:1880"; }];
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/nodered 0755 root root -"
    "d /var/lib/pihole/etc-pihole 0755 root root -"
    "d /var/lib/pihole/etc-dnsmasq.d 0755 root root -"
    "d /var/lib/traefik 0700 traefik traefik -"
  ];

  time.timeZone = "America/Chicago";

  virtualisation = {
    oci-containers = {
      backend = "podman";
      containers = {
        pihole = {
          image = "pihole/pihole:latest";
          autoStart = true;
          ports = [ "53:53/tcp" "53:53/udp" "8080:80/tcp" ];
          environment = {
            TZ = "America/Chicago";
            FTLCONF_webserver_api_password =
              "${builtins.readFile config.age.secrets.pi-hole.path}";
            FTLCONF_dns_listeningMode = "all";
            FTLCONF_dns_reply_host_force4 = "true";
            FTLCONF_dns_reply_host_IPv4 = "10.9.8.6";
          };
          volumes = [
            "/var/lib/pihole/etc-pihole:/etc/pihole"
            "/var/lib/pihole/etc-dnsmasq.d:/etc/dnsmasq.d"
          ];
          extraOptions =
            [ "--cap-add=NET_ADMIN" "--cap-add=SYS_TIME" "--cap-add=SYS_NICE" ];
        };

        # nodered = {
        #   image = "nodered/node-red:latest";
        #   ports = [ "1880:1880" ];
        #   volumes = [ "/var/lib/nodered:/data" ];
        # };
      };
    };
  };

  system.autoUpgrade.enable = false;
  system.stateVersion = "25.05";
}
