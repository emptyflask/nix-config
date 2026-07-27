{
  pkgs,
  lib,
  config,
  ...
}: {
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];

  # Only set this if using intel-vaapi-driver:
  # nixpkgs.config.packageOverrides = pkgs: {
  #   intel-vaapi-driver =
  #     pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  # };

  systemd.services.jellyfin.environment.LIBVA_DRIVER_NAME = "iHD";
  environment.sessionVariables = {LIBVA_DRIVER_NAME = "iHD";};

  hardware.graphics = {
    enable = true;

    extraPackages = with pkgs; [
      intel-ocl # Generic OpenCL support

      # For Broadwell and newer (ca. 2014+), use with LIBVA_DRIVER_NAME=iHD:
      intel-media-driver

      # For older processors, use with LIBVA_DRIVER_NAME=i965:
      # intel-vaapi-driver
      # libva-vdpau-driver

      # For 13th gen and newer:
      # intel-compute-runtime

      # For older processors:
      intel-compute-runtime-legacy1

      # For 11th gen and newer:
      # vpl-gpu-rt

      # Deprecated (may not build on recent channels):
      # intel-media-sdk
    ];
  };
}
