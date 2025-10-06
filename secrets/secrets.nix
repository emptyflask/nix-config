let
  jon-kepler =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO+sW9I8uw/5yNCQItEaqUw8QHcMgUGU4yk+HrlWKlmL";
  jon-gaudi =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGNlMSTw9hsP46IvyT4Nvrnvtki56HaX6ynmq1Ior5/a";
  jon-planck =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII717PvufsVUpt0V7Qax0Gn2RNEVmMgsSeXopZeyHNSL";
  users = [ jon-kepler jon-gaudi jon-planck ];

  kepler =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAGQWDNNNVslWp42UTWtjHrk21p0lZD7JJaJvCbyZ/4a";
  planck =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGY8I1AFXvH1D+ti+SznxNKdpmShplqCkUahENwCNyG/";
  systems = [ kepler planck ];

in {
  "jira.age" = {
    publicKeys = users ++ systems;
    armor = true;
  };
  "pi-hole.age" = {
    publicKeys = [ jon-planck planck ];
    armor = true;
  };
}
