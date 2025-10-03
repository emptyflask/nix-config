{ pkgs, ... }: {

  environment.systemPackages = [ pkgs.btrfs-progs ];

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/media/work" ];
  };
}
