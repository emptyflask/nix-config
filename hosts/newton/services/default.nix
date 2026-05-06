{ config, pkgs, lib, ... }:

{
  imports = [ ./traefik.nix ];

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        X11Forwarding = false;
      };
    };

    immich = {
      enable = true;
      mediaLocation = "/media/immich";
      openFirewall = false; # handled in networking.firewall in default.nix
    };

    pihole-ftl = {
      enable = true;
      settings.dns.upstreams = [ "9.9.9.9" "1.1.1.1" ];
    };

    pihole-web = {
      enable = true;
      # Listen on 8080 so Traefik can own port 80
      ports = [ 8080 ];
    };

    home-assistant = {
      enable = true;
      openFirewall = false; # handled in networking.firewall in default.nix
      config = {
        homeassistant = {
          name = "Home";
          unit_system = "metric";
          time_zone = config.time.timeZone;
        };
        http = {};
        default_config = {};
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /media 0755 root root -"
    "d /media/immich 0755 immich immich -"
  ];
}
