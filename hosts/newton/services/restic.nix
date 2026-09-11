{
  config,
  pkgs,
  ...
}: let
  postgresDump = "/var/backups/postgresql.sql";

  paths = [
    "/etc/ssh"
    "/etc/machine-id"
    "/var/lib/audiobookshelf"
    "/var/lib/couchdb"
    "/var/lib/hass"
    "/var/lib/hermes"
    "/var/lib/hermes-webui"
    "/var/lib/hister"
    "/var/lib/livesync"
    "/var/lib/navidrome"
    "/var/lib/paperless"
    "/media/immich"
    postgresDump
  ];

  exclude = [
    "/var/lib/hermes/lazy-deps" # reinstalled on demand via uv pip
  ];
in {
  age.secrets.restic-password.file = ../../../secrets/newton-restic-password.age;
  age.secrets.restic-b2-env.file = ../../../secrets/newton-restic-b2-env.age;

  services.restic.backups.b2 = {
    repository = "b2:emptyflask-backup:newton";
    passwordFile = config.age.secrets.restic-password.path;
    environmentFile = config.age.secrets.restic-b2-env.path;
    initialize = true;
    inherit paths exclude;

    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 5"
      "--keep-monthly 12"
    ];

    timerConfig = {
      OnCalendar = "01:00";
      Persistent = true;
    };

    backupPrepareCommand = ''
      mkdir -p "$(dirname ${postgresDump})"
      ${pkgs.sudo}/bin/sudo -u postgres ${config.services.postgresql.package}/bin/pg_dumpall > ${postgresDump}
    '';
  };
}
