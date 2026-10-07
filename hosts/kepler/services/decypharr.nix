# Media gateway that presents a qBittorrent-compatible API to Sonarr/Radarr/
# Lidarr backed by debrid providers (Premiumize et al) instead of a real
# torrent swarm - no VPN needed, since Premiumize fetches server-side. Not
# packaged in nixpkgs; see pkgs/decypharr.
#
# No nix-managed secrets here: like Jellyfin, it has its own first-run web
# setup wizard (admin login, Premiumize API key, per-Arr tokens) that writes
# into config.json in its state directory - simpler than templating secrets
# into that file ourselves. Visit https://decypharr.kepler.lan after
# deploying to complete it, then add it as a qBittorrent download client in
# Sonarr/Radarr/Lidarr (see the project's "Connecting Sonarr & Radarr" docs).
{pkgs, ...}: {
  systemd.services.decypharr = {
    description = "Decypharr (debrid media gateway)";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      ExecStart = "${pkgs.decypharr}/bin/decypharr -config /var/lib/decypharr";
      Restart = "on-failure";

      DynamicUser = true;
      StateDirectory = "decypharr";

      # Mirrors qbittorrent's/shelfmark's access to the shared download tree
      # (download_action "download" in decypharr delivers finished files
      # here the same way qbittorrent does, for the Arrs to import).
      SupplementaryGroups = ["media"];
      ReadWritePaths = ["/media/work/torrents"];
    };
  };
}
