{
  config,
  lib,
  ...
}: let
  # mkcert kepler.lan "*.kepler.lan" "*.sxsw.localhost" "*.sxswedu.localhost" "*.kepler.localhost" localhost 127.0.0.1 ::1
  certFile = ../../../nixos/security/ssl/certs/kepler.lan+7.pem;
  keyFile = config.age.secrets.kepler-tls-key.path;

  # mkcert-signed static cert, for the *.sxsw*.localhost dev domains
  proxy = host: port: {
    "${host}".extraConfig = ''
      tls ${certFile} ${keyFile}
      reverse_proxy localhost:${toString port}
    '';
  };

  # step-ca via ACME (see acmeCA below), for the real *.kepler.lan domains
  acmeProxy = host: port: {
    "${host}".extraConfig = ''
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
  age.secrets.kepler-tls-key = {
    file = ../../../secrets/kepler-tls-key.age;
    owner = "caddy";
    group = "caddy";
  };

  services.caddy = {
    enable = true;
    acmeCA = "https://ca.planck.lan:8443/acme/acme/directory";
    virtualHosts = lib.mkMerge [
      (viteProxy "id.sxsw.localhost" 5000 3036)
      (viteProxy "id.sxswedu.localhost" 5000 3036)
      (viteSslProxy "cart.sxsw.localhost" 5001 3038)
      (proxy "panelpicker.sxsw.localhost" 5003)
      (proxy "distro.sxsw.localhost" 5004)
      (viteProxy "chronos.sxsw.localhost" 5005 3037)
      (proxy "sales.sxsw.localhost" 5006)
      (viteProxy "image-manager.sxsw.localhost" 5010 3040)
      (proxy "imgproxy.sxsw.localhost" 8080)
      (proxy "minio.sxsw.localhost" 9000)
      (proxy "test.sxsw.localhost" 8999)

      (acmeProxy "audiobookshelf.kepler.lan" config.services.audiobookshelf.port)
      (acmeProxy "dockhand.kepler.lan" 3300)
      (acmeProxy "immich.kepler.lan" 2283)
      (acmeProxy "jellyfin.kepler.lan" 8096)
      (acmeProxy "usenet.kepler.lan" 6789)
      (acmeProxy "hoogle.kepler.lan" config.services.hoogle.port)

      (acmeProxy "bazarr.kepler.lan" config.services.bazarr.listenPort)
      (acmeProxy "lidarr.kepler.lan" config.services.lidarr.settings.server.port)
      (acmeProxy "prowlarr.kepler.lan" config.services.prowlarr.settings.server.port)
      (acmeProxy "radarr.kepler.lan" config.services.radarr.settings.server.port)
      (acmeProxy "seerr.kepler.lan" config.services.seerr.port)
      (acmeProxy "sonarr.kepler.lan" config.services.sonarr.settings.server.port)
    ];
  };
}
