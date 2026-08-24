{
  lib,
  pkgs,
  ...
}: {
  security = {
    pam.services.lightdm.enableGnomeKeyring = true;
    pam.services.xscreensaver = {};
    pki.certificateFiles = ["${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" ./ssl/certs/rootCA.pem];
    rtkit.enable = true;
    sudo.extraRules = lib.mkAfter [{groups = ["wheel"];}];
  };
}
