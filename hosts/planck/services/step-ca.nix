{config, ...}: {
  # Read by systemd (as root, via LoadCredential) before the step-ca service
  # drops to its own user, so this doesn't need step-ca ownership.
  age.secrets.step-ca-intermediate-password.file = ../../../secrets/step-ca-intermediate-password.age;

  services.step-ca = {
    enable = true;
    address = "0.0.0.0";
    port = 8443;
    openFirewall = true;
    intermediatePasswordFile = config.age.secrets.step-ca-intermediate-password.path;
    settings = builtins.fromJSON (builtins.readFile ./step-ca-ca.json);
  };
}
