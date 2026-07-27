let
  # newton's own SSH host key (ssh-keyscan -t ed25519 newton.lan) — lets it decrypt its own secrets
  newton = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL6TYDhbgEqa/ZQTm6CkKPmOg9JfThEYIjXaegErJCbv";
  # jon's personal key (matches nixos/users/keys/id_kepler.pub) — lets him run `agenix -e`
  jon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO+sW9I8uw/5yNCQItEaqUw8QHcMgUGU4yk+HrlWKlmL";
in {
  "openclaw.env.age".publicKeys = [newton jon];
}
