{...}: {
  imports = [
    ./caddy.nix
  ];

  # services.localCA = {
  #   enable = true;
  #   certFile = "planck.pem";
  #   keyFile = "planck-key.pem";
  #   domains = [ "planck.lan" "pi.hole" "pihole.lan" "node-red.lan" ];
  #   validityDays = 730;
  #   renewBeforeDays = 30;
  # };

  services.chrony = {
    enable = true;
    extraConfig = ''
      allow 10.9.0.0/16
      makestep 1.0 3
    '';
    servers = [
      "ns.nts.umn.edu"
      "ntp.state.mn.us"
      "time.nist.gov"
      "0.us.pool.ntp.org"
    ];
  };

  services.nfs = {
    server = {
      enable = true;
      exports = ''
        /       10.9.0.0/16(ro,insecure,sync,no_subtree_check,crossmnt,fsid=0)
        /photon 10.9.8.0/24(rw,insecure,sync,no_subtree_check)
        /photon 10.9.0.0/16(ro,insecure,sync,no_subtree_check)
        /squid  10.9.8.0/24(rw,insecure,sync,no_subtree_check)
        /squid  10.9.0.0/16(ro,insecure,sync,no_subtree_check)
      '';
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      AllowUsers = ["jon"];
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = false;
    };
  };

  services.rpcbind.enable = true;
}
