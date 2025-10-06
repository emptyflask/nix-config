{
  sops.defaultSopsFile = ../../secrets.yaml;
  # YAML is the default 
  # sops.defaultSopsFormat = "yaml";
  sops.secrets.jira_token = { };
  sops.age.keyFiles = [ ../../secrets/age-keys.txt ];
}
