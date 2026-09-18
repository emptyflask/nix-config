{...}: {
  services.caddy = {
    enable = true;
    virtualHosts = {
      "planck.lan:80".extraConfig = ''
        handle {
          header Content-Type text/html
          respond "<html><body><ul>
            <li><a href='http://dockhand.planck.lan'>Dockhand</a></li>
            <li><a href='http://pihole.planck.lan'>PiHole</a></li>
          </ul></body></html>" 200
        }
      '';
      "dockhand.planck.lan:80".extraConfig = "reverse_proxy http://localhost:3300";
      # nodeRed: container is currently disabled, see virtualisation.oci-containers below
      # "node-red.planck.lan:80".extraConfig = "reverse_proxy http://localhost:1880";
      "pi.hole:80".extraConfig = "reverse_proxy http://localhost:8080";
      "pihole.lan:80".extraConfig = "reverse_proxy http://localhost:8080";
      "pihole.planck.lan:80".extraConfig = "reverse_proxy http://localhost:8080";
    };
  };
}
