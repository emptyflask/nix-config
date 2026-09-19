{config, ...}: {
  age.secrets.immich-db-password = {
    file = ../../../secrets/immich-db-password.age;
    owner = "root";
    group = "root";
  };

  virtualisation.oci-containers.containers = {
    redis = {
      image = "docker.io/valkey/valkey:9@sha256:70739f85ad2ee01a726a965584a0f94895f01b0c60b3cc8b0aeef11eaa6888cf";
    };

    database = {
      image = "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0@sha256:bcf63357191b76a916ae5eb93464d65c07511da41e3bf7a8416db519b40b1c23";
      environment = {
        POSTGRES_USER = "postgres";
        POSTGRES_DB = "immich";
        POSTGRES_INITDB_ARGS = "--data-checksums";
      };
      environmentFiles = [config.age.secrets.immich-db-password.path];
      volumes = ["/home/jon/immich/postgres:/var/lib/postgresql/data"];
      extraOptions = ["--shm-size=128mb"];
    };

    immich-machine-learning = {
      image = "ghcr.io/immich-app/immich-machine-learning:release-cuda";
      volumes = ["immich-model-cache:/cache"];
      environment.TZ = config.time.timeZone;
      devices = ["nvidia.com/gpu=all"];
    };

    immich-server = {
      image = "ghcr.io/immich-app/immich-server:release";
      volumes = [
        "/media/repository/immich/library:/data"
        "/etc/localtime:/etc/localtime:ro"
      ];
      environment = {
        TZ = config.time.timeZone;
        DB_USERNAME = "postgres";
        DB_DATABASE_NAME = "immich";
      };
      environmentFiles = [config.age.secrets.immich-db-password.path];
      ports = ["2283:2283"];
      devices = ["nvidia.com/gpu=all"];
      dependsOn = ["database" "redis"];
    };
  };
}
