{
  config,
  lib,
  ...
}: let
  # radarr/sonarr/lidarr/bazarr all share the "media" group so they can read and
  # write each other's files (e.g. bazarr saving subtitles into a folder radarr
  # created). The servarr module hard-codes UMask "0022" (group-read-only
  # dirs/files), which blocks that; mkForce it to 002 to keep them group-writable.
  sharedMediaGroupUmask = {
    serviceConfig.UMask = lib.mkForce "0002";
  };
in {
  # openFirewall is left off (NixOS default false) for all of these: each is
  # already reachable over HTTPS via Caddy's reverse proxy at *.kepler.lan
  # (see hosts/kepler/services/caddy.nix). Opening their raw ports here would
  # make them reachable directly over plain HTTP too, bypassing that proxy
  # entirely - belt-and-suspenders exposure with no upside.
  services.bazarr = {
    enable = true;
    group = "media";
  };

  services.lidarr = {
    enable = true;
    group = "media";
  };

  services.prowlarr.enable = true;

  services.radarr = {
    enable = true;
    group = "media";
  };

  services.seerr.enable = true;

  services.sonarr = {
    enable = true;
    group = "media";
  };

  # No Caddy entry / openFirewall: it's an internal helper Prowlarr calls at
  # http://localhost:8191 (Settings > Indexers > Indexer Proxies), not
  # something with a UI worth browsing to.
  services.flaresolverr.enable = true;

  services.shelfmark = {
    enable = true;
    environment = {
      FLASK_HOST = "0.0.0.0";
      INGEST_DIR = "/media/repository/books";
      DESTINATION_AUDIOBOOK = "/media/repository/audiobooks";
      FILE_ORGANIZATION = "rename-and-organize";
      # *.kepler.lan certs are step-ca-issued. Python's requests/urllib3
      # don't consult the OS trust store (NixOS's security.pki.certificateFiles)
      # at all - they use certifi's bundled CA list unless told otherwise via
      # these two env vars, which is why prowlarr/qbittorrent connections both
      # failed cert verification even though the CA is already system-trusted.
      # Point them at the same combined bundle NixOS itself trusts, rather
      # than disabling verification per-integration.
      SSL_CERT_FILE = config.security.pki.caBundle;
      REQUESTS_CA_BUNDLE = config.security.pki.caBundle;
    };
  };

  systemd.services = {
    bazarr = sharedMediaGroupUmask;
    lidarr = sharedMediaGroupUmask;
    radarr = sharedMediaGroupUmask;
    sonarr = sharedMediaGroupUmask;

    shelfmark = lib.mkMerge [
      sharedMediaGroupUmask
      {
        # DynamicUser + ProtectSystem=strict means shelfmark can't write
        # anywhere on disk by default; punch through for its book/audiobook
        # output dirs and let it act as a "media" group member like the rest
        # of the arr stack.
        serviceConfig = {
          SupplementaryGroups = ["media"];
          ReadWritePaths = [
            "/media/repository/books"
            "/media/repository/audiobooks"
          ];
        };
      }
    ];
  };
}
