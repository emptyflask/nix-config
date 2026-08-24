{pkgs, ...}: {
  services.mpd = {
    enable = true;
    musicDirectory = "/media/repository/music";
    extraConfig = ''
      audio_output {
          type "pipewire"
          name "PipeWire"
      }
      audio_output {
          type                    "fifo"
          name                    "my_fifo"
          path                    "/tmp/mpd.fifo"
          format                  "44100:16:2"
      }
    '';
  };

  services.mpdscribble = {
    enable = true;
    endpoints = {
      "listenbrainz" = {
        passwordFile = "/home/jon/.config/rmpc/listenbrainz.pass";
        username = "emptyflask";
      };
    };
  };
}
