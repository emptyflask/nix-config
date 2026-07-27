{...}: {
  services.caddy = {
    enable = true;
    virtualHosts = {
      "newton.lan:80".extraConfig = ''
        handle {
          header Content-Type text/html
          respond "<html><body><ul>
            <li><a href='http://audiobookshelf.newton.lan'>audiobookshelf</a></li>
            <li><a href='http://immich.newton.lan'>immich</a></li>
            <li><a href='http://navidrome.newton.lan'>navidrome</a></li>
            <li><a href='http://pihole.newton.lan'>pihole</a></li>
            <li><a href='http://homeassistant.newton.lan'>homeassistant</a></li>
          </ul></body></html>" 200
        }
      '';
      "audiobookshelf.newton.lan:80".extraConfig = "reverse_proxy http://localhost:8000";
      "immich.newton.lan:80".extraConfig = "reverse_proxy http://localhost:2283";
      "navidrome.newton.lan:80".extraConfig = "reverse_proxy http://localhost:4533";
      "pihole.newton.lan:80".extraConfig = "reverse_proxy http://localhost:8080";
      "homeassistant.newton.lan:80".extraConfig = "reverse_proxy http://localhost:8123";
      "couchdb.newton.lan:80".extraConfig = "reverse_proxy http://localhost:5984";
    };
  };
}
