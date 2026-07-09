{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [./caddy.nix ./samba.nix];

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        X11Forwarding = false;
      };
    };

    audiobookshelf = {
      enable = true;
    };

    immich = {
      enable = true;
      mediaLocation = "/media/immich";
      openFirewall = true;
    };

    navidrome = {
      enable = true;
      openFirewall = true;
      settings.MusicFolder = "/media/music";
    };

    pihole-ftl = {
      enable = true;
      settings.dns.upstreams = ["1.1.1.2" "1.0.0.2"];
    };

    pihole-web = {
      enable = true;
      # Listen on 8080 so Traefik can own port 80
      ports = [8080];
    };

    home-assistant = {
      enable = true;
      openFirewall = true;
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
