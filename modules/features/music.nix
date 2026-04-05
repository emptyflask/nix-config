{ den, ... }: {
  den.aspects.music.homeManager = {
    imports = [
      ../../home-manager/services/mpd
      ../../home-manager/services/spotifyd
    ];
  };
}
