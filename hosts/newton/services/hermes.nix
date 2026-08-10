{config, ...}: {
  age.secrets.hermes-env.file = ../../../secrets/hermes.env.age;

  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;
    container = {
      enable = true;
      hostUsers = ["jon"];
    };
    environmentFiles = [config.age.secrets.hermes-env.path];
    settings = {
      memory.provider = "honcho";
      model.default = "deepseek/deepseek-v4-flash-0731";
    };
    extraDependencyGroups = ["firecrawl" "honcho" "messaging"];
  };

  # Hermes reads its persona from $HERMES_HOME/SOUL.md. In the container
  # HERMES_HOME=/data/.hermes, and /data is bind-mounted from /var/lib/hermes,
  # so the file must live at /var/lib/hermes/.hermes/SOUL.md. Symlink it to the
  # store copy — /nix/store is mounted read-only in the container, so the link
  # resolves there and the persona updates on every rebuild.
  systemd.tmpfiles.rules = [
    "d /var/lib/hermes 0750 hermes hermes -"
    "d /var/lib/hermes/.hermes 0750 hermes hermes -"
    "L+ /var/lib/hermes/.hermes/SOUL.md - - - - ${./hermes/SOUL.md}"
  ];
}
