{
  config,
  lib,
  ...
}: let
  # mkcert kepler.lan "*.kepler.lan" "*.sxsw.localhost" "*.sxswedu.localhost" "*.kepler.localhost" localhost 127.0.0.1 ::1
  certFile = "/etc/nixos/security/ssl/certs/kepler.lan+7.pem";
  keyFile = "/etc/nixos/security/ssl/private/kepler.lan+7-key.pem";

  proxy = host: port: {
    "${host}".extraConfig = ''
      tls ${certFile} ${keyFile}
      reverse_proxy localhost:${toString port}
    '';
  };

  viteProxy = host: port: vitePort: {
    "${host}".extraConfig = ''
      tls ${certFile} ${keyFile}
      handle /vite-dev/* {
        reverse_proxy localhost:${toString vitePort}
      }
      reverse_proxy localhost:${toString port}
    '';
  };

  viteSslProxy = host: port: vitePort: {
    "${host}".extraConfig = ''
      tls ${certFile} ${keyFile}
      handle /vite-dev/* {
        reverse_proxy localhost:${toString vitePort} {
          transport http {
            tls_insecure_skip_verify # works with vite basicSsl plugin
          }
        }
      }
      reverse_proxy localhost:${toString port}
    '';
  };
in {
  services.caddy = {
    enable = true;
    virtualHosts = lib.mkMerge [
      (viteProxy "id.sxsw.localhost" 5000 3036)
      (viteProxy "id.sxswedu.localhost" 5000 3036)
      (viteSslProxy "cart.sxsw.localhost" 5001 3038)
      (viteProxy "chronos.sxsw.localhost" 5005 3037)

      (proxy "panelpicker.sxsw.localhost" 5003)
      (proxy "distro.sxsw.localhost" 5004)
      (proxy "sales.sxsw.localhost" 5006)
      (proxy "image-manager.sxsw.localhost" 5010)
      (proxy "logger.sxsw.localhost" 5011)

      (proxy "audiobookshelf.kepler.lan" config.services.audiobookshelf.port)
      (proxy "bazarr.kepler.lan" config.services.bazarr.listenPort)
      (proxy "immich.kepler.lan" 2283)
      (proxy "immich.kepler.lan" 2283)
      (proxy "jellyfin.kepler.lan" 8096)
      (proxy "lidarr.kepler.lan" config.services.lidarr.settings.server.port)
      (proxy "prowlarr.kepler.lan" config.services.prowlarr.settings.server.port)
      (proxy "radarr.kepler.lan" config.services.radarr.settings.server.port)
      (proxy "seerr.kepler.lan" config.services.seerr.port)
      (proxy "sonarr.kepler.lan" config.services.sonarr.settings.server.port)
      (proxy "usenet.kepler.lan" 6789)
      (proxy "hoogle.kepler.lan" config.services.hoogle.port)
    ];
  };
}
