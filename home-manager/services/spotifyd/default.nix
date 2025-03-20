{ pkgs, ... }:
with pkgs;
{
  services.spotifyd = {
    enable = false;
    settings = {
      global = {
        username     = "emptyflask";
        password_cmd = "${pkgs.pass}/bin/pass spotify";
        device_name  = "nixos-spotifyd";
        bitrate      = 320;
        backend      = "alsa";
        cache_patch  = "/tmp/spotifyd";
      };
    };
  };
}
