{ ... }: {
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "newton";
        "server role" = "standalone server";
        "map to guest" = "Bad User";
        "server min protocol" = "SMB2";
        "vfs objects" = "catia fruit streams_xattr";
        "fruit:aapl" = "yes";
        "fruit:metadata" = "stream";
        "fruit:model" = "MacSamba";
        "fruit:posix_rename" = "yes";
        "fruit:veto_appledouble" = "no";
        "fruit:wipe_intentionally_left_blank_rfork" = "yes";
        "fruit:delete_empty_adfiles" = "yes";
      };
      media = {
        path = "/media";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "force user" = "jon";
      };
      jon = {
        path = "/home/jon";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "jon";
      };
    };
  };

  services.samba.nmbd.enable = false;

  services.samba-wsdd.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish.enable = true;
    publish.userServices = true;
  };

  services.nfs.server = {
    enable = true;
    exports = ''
      /media 10.9.8.0/24(rw,sync,no_subtree_check,root_squash)
    '';
  };
}
