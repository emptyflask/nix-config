{
  lib,
  pkgs,
  ...
}: {
  security = {
    pam.services = {
      lightdm.enableGnomeKeyring = true;
      xscreensaver.enable = true;
    };
    pki.certificateFiles = [
      "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      ./ssl/certs/rootCA.pem # mkcert root, for *.sxsw.localhost / *.sxswedu.localhost dev certs
      ./ssl/certs/step-ca-root.pem # step-ca root, for *.kepler.lan / *.newton.lan / *.planck.lan
    ];
    rtkit.enable = true;
    sudo.extraRules = lib.mkAfter [{groups = ["wheel"];}];
  };
}
