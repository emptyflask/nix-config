{config, ...}: {
  # The LiveSync settings JSON holds the CouchDB URL/credentials AND the E2EE
  # passphrase, so the whole file is a secret. Create it with:
  #   agenix -e secrets/livesync-settings.age
  # and paste a settings.json like:
  #   {
  #     "couchDB_URI": "http://127.0.0.1:5984",
  #     "couchDB_USER": "...",
  #     "couchDB_PASSWORD": "...",
  #     "couchDB_DBNAME": "obsidian",
  #     "encrypt": true,
  #     "passphrase": "<same passphrase as your Obsidian devices>",
  #     "isConfigured": true
  #   }
  # Easiest way to get a correct, obfuscation-matching file: export a Setup URI
  # from an existing Obsidian client and run `livesync-cli <db> --settings <f>
  # setup <uri> --write-settings` once locally, then encrypt the resulting JSON.
  age.secrets.livesync-settings = {
    file = ../../../secrets/livesync-settings.age;
    owner = "hermes";
    group = "hermes";
  };

  # Run the sync daemon as the hermes user so hermes reads/writes the vault
  # directly (no cross-user permission juggling). CouchDB runs locally on newton.
  services.livesync-cli = {
    enable = true;
    user = "hermes";
    group = "hermes";
    databasePath = "/var/lib/livesync/db";
    vaultPath = "/var/lib/hermes/vault";
    settingsFile = config.age.secrets.livesync-settings.path;
  };

  # A secret-only change (re-encrypting settings.json) doesn't alter the systemd
  # unit definition, so `nixos-rebuild switch` won't restart the daemon on its
  # own — it keeps its old in-memory settings until restarted. Tie a restart to
  # the encrypted file so switching in new settings takes effect automatically.
  systemd.services.livesync-cli.restartTriggers = [config.age.secrets.livesync-settings.file];

  # The CLI requires its database directory to already exist, and hermes needs
  # the vault directory present. Both owned by hermes to match the service user.
  systemd.tmpfiles.rules = [
    "d /var/lib/livesync 0750 hermes hermes - -"
    "d /var/lib/livesync/db 0750 hermes hermes - -"
    "d /var/lib/hermes/vault 0750 hermes hermes - -"
  ];
}
