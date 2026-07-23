{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [./caddy.nix ./samba.nix];

  services = {
    audiobookshelf = {
      enable = true;
    };

    couchdb = {
      enable = true;
      adminPass = "couchdb";
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
        http = {
          use_x_forwarded_for = true;
          trusted_proxies = ["127.0.0.1" "::1"];
        };
        default_config = {};
      };
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

    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        X11Forwarding = false;
      };
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
  };

  systemd.tmpfiles.rules = [
    "d /media 0755 root root -"
    "d /media/immich 0755 immich immich -"
  ];
}
