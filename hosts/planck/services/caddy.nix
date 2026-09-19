{...}: {
  services.caddy = {
    enable = true;
    acmeCA = "https://ca.planck.lan:8443/acme/acme/directory";
    virtualHosts = {
      "planck.lan".extraConfig = ''
        handle {
          header Content-Type text/html
          respond "<html><body><ul>
            <li><a href='https://adguard.planck.lan'>AdGuard Home</a></li>
            <li><a href='https://dockhand.planck.lan'>Dockhand</a></li>
          </ul></body></html>" 200
        }
      '';
      "adguard.planck.lan".extraConfig = "reverse_proxy http://localhost:8080";
      "dockhand.planck.lan".extraConfig = "reverse_proxy http://localhost:3300";
      # nodeRed: container is currently disabled, see virtualisation.oci-containers below
      # "node-red.planck.lan".extraConfig = "reverse_proxy http://localhost:1880";
    };
  };
}
