{config, ...}: let
  webuiPort = 8080;
  downloadDir = "/media/work/torrents";
in {
  # Read by the wg-quick netns setup (runs as root) before qbittorrent starts.
  age.secrets.protonvpn-arrs.file = ../../../secrets/protonvpn-arrs.age;

  # ProtonVPN gave this config NAT-PMP/port forwarding = off, so there's no
  # externally-reachable listening port for incoming peer connections -
  # downloads still work, just with degraded swarm connectivity for now.
  vpnNamespaces.arrsvpn = {
    enable = true;
    wireguardConfigFile = config.age.secrets.protonvpn-arrs.path;
    portMappings = [
      {
        from = webuiPort;
        to = webuiPort;
      }
    ];
  };

  systemd.services.qbittorrent.vpnConfinement = {
    enable = true;
    vpnNamespace = "arrsvpn";
  };

  systemd.tmpfiles.settings."10-qbittorrent-downloads" = {
    "${downloadDir}/complete"."d" = {
      mode = "775";
      user = "qbittorrent";
      group = "media";
    };
    "${downloadDir}/incomplete"."d" = {
      mode = "775";
      user = "qbittorrent";
      group = "media";
    };
  };

  services.qbittorrent = {
    enable = true;
    group = "media";
    inherit webuiPort;
    serverConfig = {
      LegalNotice.Accepted = true;
      Preferences = {
        # Behind Caddy's reverse proxy, the Host header is qbittorrent.kepler.lan,
        # not localhost/the bind address - qBittorrent rejects that by default.
        WebUI = {
          HostHeaderValidation = false;
          Username = "admin";
          # PBKDF2-HMAC-SHA512, 100k iterations, random salt - not reversible,
          # safe to keep in the (world-readable) Nix store like any password hash.
          Password_PBKDF2 = "@ByteArray(hFtaKJ+zRBES9lTgXB/HQw==:UM7NKRSXpfmHib+e34lpRCV2ltW2i4mJ8meTBhSA+5skp5PemjIknP5ADRFS2qw2wh7f91p8Bs6cP8ik4Ayc/w==)";
        };
        Downloads = {
          SavePath = "${downloadDir}/complete";
          TempPath = "${downloadDir}/incomplete";
          TempPathEnabled = true;
        };
      };
    };
  };
}
