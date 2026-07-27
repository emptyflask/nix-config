{config, ...}: {
  age.secrets.pihole-env.file = ../../../secrets/pihole.env.age;

  services = {
    pihole-ftl = {
      enable = true;
      settings.dns.upstreams = ["1.1.1.2" "1.0.0.2"];
    };

    pihole-web = {
      enable = true;
      ports = [8080];
    };
  };

  systemd.services.pihole-ftl.serviceConfig.EnvironmentFile =
    config.age.secrets.pihole-env.path;
}
