{config, ...}: {
  # Admin password created with:
  #   echo '<password>' | agenix -e secrets/paperless-admin-pass.age
  age.secrets.paperless-admin-pass.file = ../../../secrets/paperless-admin-pass.age;

  services.paperless = {
    enable = true;
    address = "127.0.0.1";
    port = 28981;
    database.createLocally = true;
    configureTika = true;
    passwordFile = config.age.secrets.paperless-admin-pass.path;
    settings = {
      PAPERLESS_URL = "http://paperless.newton.lan";
      PAPERLESS_OCR_LANGUAGE = "eng";
    };
  };
}
