{ pkgs, ... }:

{
  services.mpd = {
    enable = true;
    musicDirectory = "/media/repository/music";
  };
}
