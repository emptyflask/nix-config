{pkgs, ...}: {
  # imports = [ <home-manager/nixos> ];

  nix.settings.trusted-users = ["root" "jon"];

  environment.homeBinInPath = true;
  environment.shells = with pkgs; [bashInteractive zsh];

  users = {
    users.root.initialHashedPassword = "";

    users.jon = {
      description = "Jon Roberts";
      initialPassword = "changeme";
      isNormalUser = true;
      uid = 1000;
      extraGroups = [
        "adbusers"
        "audio"
        "dialout"
        "docker"
        "libvirtd"
        "media"
        "mlocate"
        "networkmanager"
        "plex"
        "podman"
        "postgres"
        "storage"
        "usenet"
        "vboxusers"
        "wheel"
      ];
      shell = pkgs.zsh;

      openssh.authorizedKeys.keys = [
        (builtins.readFile ./keys/id_gaudi.pub)
        (builtins.readFile ./keys/id_kepler.pub)
        (builtins.readFile ./keys/id_raspberrypi.pub)
        (builtins.readFile ./keys/id_sargent.pub)
      ];
    };

    users.plex = {
      group = "media";
      isSystemUser = true;
    };
    groups.media = {};
  };

  # home-manager = {
  #   useUserPackages = true;
  #   users.jon = import ./jon/home-manager/home-nixos.nix;
  # };
}
