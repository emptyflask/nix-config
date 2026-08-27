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
  "secrets/couchdb-admin-pass.age".publicKeys = [hosts.newton jon];
  "secrets/hermes-webui.env.age".publicKeys = [hosts.newton jon];
  "secrets/hermes.env.age".publicKeys = [hosts.newton jon];
  "secrets/hister.env.age".publicKeys = [hosts.newton jon];
  "secrets/kepler-tls-key.age".publicKeys = [hosts.kepler jon];
  "secrets/livesync-settings.age".publicKeys = [hosts.newton jon];
  "secrets/openclaw.env.age".publicKeys = [hosts.newton jon];
  "secrets/pihole.env.age".publicKeys = [hosts.newton hosts.planck jon];

  # personal
  "secrets/ghi-token.age".publicKeys = [jon];
  "secrets/jira-token.age".publicKeys = [jon];
  "secrets/nix-access-tokens.age".publicKeys = [jon];
}
