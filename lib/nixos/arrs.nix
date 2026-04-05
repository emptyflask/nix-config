{...}: {
  services.bazarr = {
    enable = true;
    group = "media";
    openFirewall = true;
  };

  services.jellyseerr = {
    enable = true;
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

  services.sonarr = {
    enable = true;
    group = "media";
    openFirewall = true;
  };
}
