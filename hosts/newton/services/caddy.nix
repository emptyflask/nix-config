{...}: {
  services.caddy = {
    enable = true;
    acmeCA = "https://ca.planck.lan:8443/acme/acme/directory";
    virtualHosts = {
      "newton.lan".extraConfig = ''
        handle {
          header Content-Type text/html
          respond "<html><body><ul>
            <li><a href='https://adguard.newton.lan'>AdGuard Home</a></li>
            <li><a href='https://audiobookshelf.newton.lan'>Audiobookshelf</a></li>
            <li><a href='https://hermes-webui.newton.lan'>Hermes Web UI</a></li>
            <li><a href='https://hister.newton.lan'>Hister (browser history search)</a></li>
            <li><a href='https://homeassistant.newton.lan'>Home Assistant</a></li>
            <li><a href='https://immich.newton.lan'>Immich</a></li>
            <li><a href='https://navidrome.newton.lan'>Navidrome</a></li>
            <li><a href='https://paperless.newton.lan'>Paperless-ngx</a></li>
          </ul></body></html>" 200
        }
      '';
      "adguard.newton.lan".extraConfig = "reverse_proxy http://localhost:8080";
      "audiobookshelf.newton.lan".extraConfig = "reverse_proxy http://localhost:8000";
      "couchdb.newton.lan".extraConfig = "reverse_proxy http://localhost:5984";
      "hermes-webui.newton.lan".extraConfig = "reverse_proxy http://localhost:8787";
      "hister.newton.lan".extraConfig = "reverse_proxy http://localhost:4433";
      "homeassistant.newton.lan".extraConfig = "reverse_proxy http://localhost:8123";
      "immich.newton.lan".extraConfig = "reverse_proxy http://localhost:2283";
      "navidrome.newton.lan".extraConfig = "reverse_proxy http://localhost:4533";
      "paperless.newton.lan".extraConfig = "reverse_proxy http://localhost:28981";
    };
  };
}
