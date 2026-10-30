let
  hosts = {
    gaudi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGRcSc0YCSViPmYIolyJgPG0g6RWAQqUpFB65LsjKWb9";
    kepler = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAGQWDNNNVslWp42UTWtjHrk21p0lZD7JJaJvCbyZ/4a";
    newton = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL6TYDhbgEqa/ZQTm6CkKPmOg9JfThEYIjXaegErJCbv";
    planck = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGY8I1AFXvH1D+ti+SznxNKdpmShplqCkUahENwCNyG/";
  };
  # nix run github:ryantm/agenix -- -i ~/.ssh/id_agenix -e secrets/foo.age
  jon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHVg6SqixEZUfr6qNNWL58yo8WT/Lz1Io+1xxh6MCHiK";
in {
  # services
  "brscan-ftp-jon-pass.age".publicKeys = [hosts.newton jon];
  "brscan-ftp-dana-pass.age".publicKeys = [hosts.newton jon];
  "couchdb-admin-pass.age".publicKeys = [hosts.newton jon];
  "hermes-webui.env.age".publicKeys = [hosts.newton jon];
  "hermes.env.age".publicKeys = [hosts.newton jon];
  "hister.env.age".publicKeys = [hosts.newton jon];
  "immich-db-password.age".publicKeys = [hosts.kepler jon];
  "kepler-tls-key.age".publicKeys = [hosts.kepler jon];
  "protonvpn-arrs.age".publicKeys = [hosts.kepler jon];
  "livesync-settings.age".publicKeys = [hosts.newton jon];
  "openclaw.env.age".publicKeys = [hosts.newton jon];
  "paperless-admin-pass.age".publicKeys = [hosts.newton jon];
  "paperless-ai.env.age".publicKeys = [hosts.newton jon];
  "step-ca-intermediate-password.age".publicKeys = [hosts.planck jon];
  "restic-password.age".publicKeys = [hosts.kepler jon];
  "restic-b2-env.age".publicKeys = [hosts.kepler jon];
  "newton-restic-password.age".publicKeys = [hosts.newton jon];
  "newton-restic-b2-env.age".publicKeys = [hosts.newton jon];

  # personal
  "rootca-key.age".publicKeys = [jon];
  "ghi-token.age".publicKeys = [jon];
  "jira-token.age".publicKeys = [jon];
  "nix-access-tokens.age".publicKeys = [jon];
  "typesafe-api-key.age".publicKeys = [jon];
}
