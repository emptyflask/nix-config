{lib, ...}: let
  # radarr/sonarr/lidarr/bazarr all share the "media" group so they can read and
  # write each other's files (e.g. bazarr saving subtitles into a folder radarr
  # created). The servarr module hard-codes UMask "0022" (group-read-only
  # dirs/files), which blocks that; mkForce it to 002 to keep them group-writable.
  sharedMediaGroupUmask = {
    serviceConfig.UMask = lib.mkForce "0002";
  };
in {
  services.bazarr = {
    enable = true;
    group = "media";
    openFirewall = true;
  };

  services.lidarr = {
    enable = true;
    group = "media";
    openFirewall = true;
  };

  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  services.radarr = {
    enable = true;
    group = "media";
    openFirewall = true;
  };

  services.seerr = {
    enable = true;
    openFirewall = true;
  };

  services.sonarr = {
    enable = true;
    group = "media";
    openFirewall = true;
  };

  systemd.services = {
    bazarr = sharedMediaGroupUmask;
    lidarr = sharedMediaGroupUmask;
    radarr = sharedMediaGroupUmask;
    sonarr = sharedMediaGroupUmask;
  };
}
