{
  config,
  lib,
  pkgs,
  ...
}: let
  # One FTP login per person. Each is chrooted into their own subdir of
  # paperless's consumption dir; PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS (see
  # ./paperless.nix) auto-tags whatever lands there with their name.
  scanUsers = ["jon" "dana"];

  userName = name: "brscan-${name}";
  homeDir = name: "${config.services.paperless.consumptionDir}/${name}";
in {
  # Password hashes created with, for each user:
  #   mkpasswd -m sha-512 | agenix -e secrets/brscan-ftp-<name>-pass.age
  age.secrets = lib.genAttrs (map (name: "brscan-ftp-${name}-pass") scanUsers) (secretName: {
    file = ../../../secrets/${secretName}.age;
  });

  users.users = lib.genAttrs (map userName scanUsers) (u: let
    name = lib.removePrefix "brscan-" u;
  in {
    isSystemUser = true;
    group = "nogroup";
    home = homeDir name;
    createHome = false;
    hashedPasswordFile = config.age.secrets."brscan-ftp-${name}-pass".path;
    shell = "${pkgs.shadow}/bin/nologin";
  });

  # setgid (2770) so uploaded files inherit the paperless group instead of
  # the ftp user's own primary group -- otherwise paperless-consumer can't
  # read what vsftpd just wrote.
  systemd.tmpfiles.rules =
    map (name: "d '${homeDir name}' 2770 ${userName name} paperless -") scanUsers;

  # The vsftpd module only wires up its PAM service when using virtual
  # users; for plain local-user auth we need the default rules ourselves,
  # or every login falls through to pam_warn and gets denied.
  security.pam.services.vsftpd = {};

  # Self-signed cert for FTPS, generated on first start if missing. vsftpd
  # only speaks explicit TLS (AUTH TLS on port 21) -- set the printer's
  # profile to "TLS (Explicit Mode)", not "SSL (Implicit Mode)".
  systemd.services.vsftpd.preStart = ''
    cert=/var/lib/vsftpd/cert.pem
    key=/var/lib/vsftpd/key.pem
    if [ ! -f "$cert" ]; then
      mkdir -p /var/lib/vsftpd
      ${pkgs.openssl}/bin/openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
        -keyout "$key" -out "$cert" -subj "/CN=paperless.newton.lan"
      chmod 600 "$key"
    fi
  '';

  services.vsftpd = {
    enable = true;
    localUsers = true;
    writeEnable = true;
    chrootlocalUser = true;
    allowWriteableChroot = true;
    userlistEnable = true;
    userlistDeny = false;
    userlist = map userName scanUsers;
    rsaCertFile = "/var/lib/vsftpd/cert.pem";
    rsaKeyFile = "/var/lib/vsftpd/key.pem";
    forceLocalLoginsSSL = true;
    forceLocalDataSSL = true;
    extraConfig = ''
      check_shell=NO
      pasv_enable=YES
      pasv_min_port=21000
      pasv_max_port=21010
      pasv_address=10.9.8.10
      xferlog_enable=YES
      # Group-readable/writable so files land accessible to the paperless
      # group (see the setgid consume dirs above).
      local_umask=007
      # The printer's FTPS client always wraps the data connection in TLS
      # (regardless of forceLocalDataSSL) but doesn't resume the control
      # channel's TLS session for it. vsftpd's default (require_ssl_reuse=YES)
      # then silently discards the transfer: the handshake completes on the
      # wire, but the upload lands as a 0-byte file. Confirmed via packet
      # capture -- real bytes flow on the passive port, file stays empty.
      require_ssl_reuse=NO
    '';
  };

  networking.firewall = {
    allowedTCPPorts = [21];
    allowedTCPPortRanges = [
      {
        from = 21000;
        to = 21010;
      }
    ];
  };
}
