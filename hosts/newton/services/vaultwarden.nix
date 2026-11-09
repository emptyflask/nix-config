# Bitwarden-compatible password server, LAN/VPN only (behind caddy at
# vault.newton.lan). Clients keep an offline copy of the vault, so newton
# being down only blocks edits; restic.nix ships backupDir to B2.
{...}: {
  services.vaultwarden = {
    enable = true;
    domain = "vault.newton.lan";
    # Consistent sqlite snapshot plus attachments/keys; restic.nix refreshes
    # it right before each run.
    backupDir = "/var/backups/vaultwarden";
    config = {
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      # Open only long enough to create the account, then set to false.
      SIGNUPS_ALLOWED = true;
      EXPERIMENTAL_CLIENT_FEATURE_FLAGS = "fill-assist-targeting-rules,pm-32009-new-item-types,pm-34171-card-scanner";
    };
  };
}
