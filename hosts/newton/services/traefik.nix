{ config, lib, ... }:

{
  services.traefik = {
    enable = true;

    staticConfigOptions = {
      api = {
        dashboard = false;
        insecure = false;
      };
      entryPoints.web = { address = ":80"; };
    };

    dynamicConfigOptions = {
      http = let
        proxy = host: port: {
          routers."${host}" = {
            rule = "Host(`${host}`)";
            entryPoints = [ "web" ];
            service = host;
          };
          services."${host}".loadBalancer.servers = [
            { url = "http://localhost:${toString port}/"; }
          ];
        };
      in
        lib.mkMerge [
          (proxy "immich.newton.lan"        2283)
          (proxy "pihole.newton.lan"        8080)
          (proxy "homeassistant.newton.lan" 8123)
        ];
    };
  };
}
