{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [./caddy.nix ./pihole.nix ./samba.nix];

  age.secrets.couchdb-admin-pass = {
    file = ../../../secrets/couchdb-admin-pass.age;
    owner = "couchdb";
    group = "couchdb";
  };

  services = {
    audiobookshelf = {
      enable = true;
    };

    couchdb = {
      enable = true;
      extraConfigFiles = [config.age.secrets.couchdb-admin-pass.path];
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

  };

  systemd.tmpfiles.rules = [
    "d /media 0755 root root -"
    "d /media/immich 0755 immich immich -"
  ];
}
