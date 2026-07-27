{pkgs, ...}: {
  environment.systemPackages = [pkgs.btrfs-progs];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/22f15aa1-8b19-461b-bf4d-77c84af52416";
    fsType = "ext4";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/38f4dc53-7d00-4f26-b317-8fffced6842c";
    fsType = "btrfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/16EB-79D4";
    fsType = "vfat";
  };

  fileSystems."/media/repository" = {
    device = "/dev/disk/by-uuid/7a01cf63-eeb7-4f16-8d51-8ba9b687bd87";
    fsType = "ext4";
    options = [
      "noatime"
      "nofail"
    ];
  };

  fileSystems."/mnt/newton/media" = {
    device = "10.9.8.10:/media";
    fsType = "nfs";
    options = ["nfsvers=4" "nofail" "x-systemd.automount"];
  };

  fileSystems."/media/work" = {
    device = "/dev/disk/by-uuid/9c11d22f-1bf9-44b8-b60b-ddcd592bc011";
    fsType = "btrfs";
  };

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = ["/home" "/media/work"];
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/3e3a1f6e-6d70-43bf-9900-6f70a624b96a";}
    {device = "/swapfile";}
  ];
}
