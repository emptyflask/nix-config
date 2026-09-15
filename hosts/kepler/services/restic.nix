{
  config,
  pkgs,
  ...
}: let
  immichDbDump = "/var/backups/immich-postgres.sql";

  paths = [
    "/home/jon"
    "/etc/ssh"
    "/etc/machine-id"
    "/media/repository/immich/library"
    immichDbDump
  ];

  exclude = [
    "**/.cache"
    "**/node_modules"
    "/home/jon/.cabal"
    "/home/jon/.cargo"
    "/home/jon/.config/.android"
    "/home/jon/.gem"
    "/home/jon/.gradle"
    "/home/jon/.local/share/Steam"
    "/home/jon/.local/share/Tabletop Simulator"
    "/home/jon/.local/share/containers"
    "/home/jon/.local/share/flatpak"
    "/home/jon/.local/share/fonts-orig"
    "/home/jon/.local/share/pnpm"
    "/home/jon/.local/share/yarn"
    "/home/jon/.meteor"
    "/home/jon/.minikube"
    "/home/jon/.npm"
    "/home/jon/.npm-global"
    "/home/jon/.stack"
    "/home/jon/.terraform.d"
    "/home/jon/Android"
    "/home/jon/Downloads"
    "/home/jon/dev/**/tmp"
    "/home/jon/immich/postgres" # raw live pg data dir; immichDbDump above is the consistent copy
    "/home/jon/src"
    "/home/jon/tmp"
  ];

  pruneOpts = [
    "--keep-daily 7"
    "--keep-weekly 5"
    "--keep-monthly 12"
  ];

  localTimerConfig = {
    OnCalendar = "03:00";
    Persistent = true;
  };

  b2TimerConfig = {
    OnCalendar = "04:00";
    Persistent = true;
  };

  backupPrepareCommand = ''
    mkdir -p "$(dirname ${immichDbDump})"
    ${pkgs.docker}/bin/docker exec immich_postgres pg_dumpall -U postgres > ${immichDbDump}
  '';
in {
  age.secrets.restic-password.file = ../../../secrets/restic-password.age;
  age.secrets.restic-b2-env.file = ../../../secrets/restic-b2-env.age;

  services.restic.backups = {
    local = {
      repository = "/media/green/restic";
      passwordFile = config.age.secrets.restic-password.path;
      initialize = true;
      inherit paths exclude pruneOpts backupPrepareCommand;
      timerConfig = localTimerConfig;
    };

    b2 = {
      repository = "b2:emptyflask-backup:kepler";
      passwordFile = config.age.secrets.restic-password.path;
      environmentFile = config.age.secrets.restic-b2-env.path;
      initialize = true;
      inherit paths exclude pruneOpts backupPrepareCommand;
      timerConfig = b2TimerConfig;
    };
  };

  # skip the local job quietly when the removable drive isn't mounted,
  # instead of failing every day it's unplugged
  systemd.services.restic-backups-local.unitConfig.ConditionPathIsMountPoint = "/media/green";
}
