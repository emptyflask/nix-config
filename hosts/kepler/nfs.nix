{ ... }: {
  boot.supportedFilesystems = [ "nfs" ];
  services.rpcbind.enable = true; # needed for NFS

  systemd.mounts = let
    commonMountOptions = {
      type = "nfs";
      mountConfig = { Options = "noatime,nfsvers=4.2"; };
    };

  in [
    (commonMountOptions // {
      what = "planck:/photon";
      where = "/mnt/photon";
    })

    (commonMountOptions // {
      what = "planck:/squid";
      where = "/mnt/squid";
    })
  ];

  systemd.automounts = let
    commonAutoMountOptions = {
      wantedBy = [ "multi-user.target" ];
      automountConfig = { TimeoutIdleSec = "600"; };
    };

  in [
    (commonAutoMountOptions // { where = "/mnt/photon"; })
    (commonAutoMountOptions // { where = "/mnt/squid"; })
  ];
}
