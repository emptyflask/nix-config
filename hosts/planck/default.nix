{ inputs, outputs, lib, config, pkgs, ... }:

let
  piholeDomain = "pihole.emptyflask.dev";
  nodeRedDomain = "node-red.emptyflask.net";
in
{
  imports = [
    # ../../nixos/security
    # ../../nixos/services
    ./hardware-configuration.nix
    ../../nixos/users
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

  networking = {
    hostName = "planck";
    useDHCP = true;
    firewall.enable = true;
    firewall.allowPing = true;
    firewall.allowedTCPPorts = [ 22 53 80 ];
    firewall.allowedUDPPorts = [ 53 ];
    nameservers = ["1.1.1.1" "1.0.0.1"];
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
    libraspberrypi
    lsof
    nmap
    mkpasswd
    pciutils
    raspberrypi-eeprom
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

  # services.couchdb.enable = true;
  # services.docker.enable = true;

  services.nfs.server = {
    enable = true;
    exports = ''
      /export 10.9.0.0/16(fsid=0,crossmnt,insecure,sync,no_subtree_check)
      /export/photon 10.9.8.0/24(rw,insecure,sync,no_subtree_check)
      /export/photon 10.9.0.0/16(ro,insecure,sync,no_subtree_check)
      /export/squid 10.9.8.0/24(rw,insecure,sync,no_subtree_check)
      /export/squid 10.9.0.0/16(ro,insecure,sync,no_subtree_check)
    '';
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
          ];
        };

        nodered = {
          image = "nodered/node-red:latest";
          ports = [ "127.0.0.1:1880:1880" ];
          volumes = [ "/var/lib/nodered:/data" ]; 
        };
      };
    };
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "planck";
        "netbios name" = "planck";
        "security" = "user";
        #"use sendfile" = "yes";
        #"max protocol" = "smb2";
        # note: localhost is the ipv6 localhost ::1
        "hosts allow" = "10.9.8. 10.9.11. localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      public = {
        "path" = "/home/jon/public";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "jon";
        "force group" = "users";
      };
      incoming = {
        "path" = "/home/jon/public/incoming";
        "browseable" = "no";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "jon";
        "force group" = "users";
      };

      "public" = {
        "path" = "/mnt/sda1/public";
        "browseable" = "yes";
        "read only" = "yes";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "jon";
        "force group" = "users";
      };
      "incoming" = {
        "path" = "/mnt/sda1/public/incoming";
        "browseable" = "no";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "jon";
        "force group" = "users";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  services.traefik = {
    enable = true;
    staticConfigOptions = {
      entryPoints = {
        web = {
          address = ":80";
          asDefault = true;
          http.redirections.entrypoint = {
            to = "websecure";
            scheme = "https";
          };
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
    };

    dynamicConfigOptions = {
      http.routers = {
        pihole = {
          rule = "Host(`${piholeDomain}`)";
          entryPoints = [ "websecure" ];
          service = "pihole";
          tls.certResolver = "myresolver";
        };
        nodeRed = {
          rule = "Host(`${nodeRedDomain}`)";
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

#  users.users.traefik = {
#    isSystemUser = true;
#    group = "traefik";
#  };
#
#  users.groups.traefik = {};

  system.autoUpgrade.enable = false;
  system.stateVersion = "25.05";
}
