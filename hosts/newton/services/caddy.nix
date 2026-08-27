{...}: {
  services.caddy = {
    enable = true;
    virtualHosts = {
      "newton.lan:80".extraConfig = ''
        handle {
          header Content-Type text/html
          respond "<html><body><ul>
            <li><a href='http://audiobookshelf.newton.lan'>Audiobookshelf</a></li>
            <li><a href='http://hermes-webui.newton.lan'>Hermes Web UI</a></li>
            <li><a href='http://hister.newton.lan'>Hister (browser history search)</a></li>
            <li><a href='http://homeassistant.newton.lan'>Home Assistant</a></li>
            <li><a href='http://immich.newton.lan'>Immich</a></li>
            <li><a href='http://navidrome.newton.lan'>Navidrome</a></li>
            <li><a href='http://pihole.newton.lan'>PiHole</a></li>
          </ul></body></html>" 200
        }
      '';
      "audiobookshelf.newton.lan:80".extraConfig = "reverse_proxy http://localhost:8000";
      "couchdb.newton.lan:80".extraConfig = "reverse_proxy http://localhost:5984";
      "hermes-webui.newton.lan:80".extraConfig = "reverse_proxy http://localhost:8787";
      "hister.newton.lan:80".extraConfig = "reverse_proxy http://localhost:4433";
      "homeassistant.newton.lan:80".extraConfig = "reverse_proxy http://localhost:8123";
      "immich.newton.lan:80".extraConfig = "reverse_proxy http://localhost:2283";
      "navidrome.newton.lan:80".extraConfig = "reverse_proxy http://localhost:4533";
      "pihole.newton.lan:80".extraConfig = "reverse_proxy http://localhost:8080";
    };
  };
}
