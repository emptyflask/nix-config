{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.localCA;
in {
  options.services.localCA = {
    enable = mkEnableOption "local self-signed CA and certs";

    domains = mkOption {
      type = types.listOf types.str;
      default = [];
      example = [ "pi.hole" "pihole.lan" "node-red.lan" ];
      description = "Domain names to include in the SAN certificate.";
    };

    stateDir = mkOption {
      type = types.path;
      default = "/etc/ssl/simple-tls-ca";
      description = "Directory where the CA and certs are stored.";
    };

    certFile = mkOption {
      type = types.str;
      default = "lan.pem";
      description = "Filename of the issued certificate.";
    };

    keyFile = mkOption {
      type = types.str;
      default = "lan-key.pem";
      description = "Filename of the issued private key.";
    };

    validityDays = mkOption {
      type = types.int;
      default = 365;
      description = "Lifetime of the issued certificate in days.";
    };

    renewBeforeDays = mkOption {
      type = types.int;
      default = 30;
      description = "Renew the certificate this many days before expiration.";
    };

    certFilePath = mkOption {
      type = types.path;
      readOnly = true;
      description = "Resolved path to the issued certificate.";
    };
  
    keyFilePath = mkOption {
      type = types.path;
      readOnly = true;
      description = "Resolved path to the private key.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.simple-tls-ca ];

    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir} 0750 root root -"
    ];

    # Service to issue/renew certificate
    systemd.services.local-ca-issue = {
      description = "Generate or renew local TLS certificates";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = ''
          set -e
          cd ${cfg.stateDir}

          # Initialize CA if needed
          if [ ! -f ca.pem ]; then
            ${pkgs.simple-tls-ca}/bin/simple-tls-ca init
          fi

          # Issue new cert if missing or expiring soon
          need_issue=0
          if [ ! -f ${cfg.certFile} ]; then
            need_issue=1
          else
            expiry=$(openssl x509 -enddate -noout -in ${cfg.certFile} | cut -d= -f2)
            expiry_ts=$(date -d "$expiry" +%s)
            now_ts=$(date +%s)
            renew_before=$(( ${cfg.renewBeforeDays} * 86400 ))
            if [ $(( expiry_ts - now_ts )) -lt $renew_before ]; then
              need_issue=1
            fi
          fi

          if [ "$need_issue" -eq 1 ]; then
            ${pkgs.simple-tls-ca}/bin/simple-tls-ca issue ${concatStringsSep " " cfg.domains} \
              --cert ${cfg.certFile} \
              --key ${cfg.keyFile} \
              --days ${toString cfg.validityDays}
          fi
        '';
      };
    };

    # Timer: run daily to check if renewal needed
    systemd.timers.local-ca-issue = {
      description = "Check and renew local TLS certs if needed";
      wantedBy = [ "timers.target" ];
      timerConfig.OnCalendar = "daily";
      timerConfig.Persistent = true;
    };

    # Trust the root CA system-wide
    security.pki.certificateFiles = [ "${cfg.stateDir}/ca.pem" ];

    services.localCA.certFilePath = "${cfg.stateDir}/${cfg.certFile}";
    services.localCA.keyFilePath  = "${cfg.stateDir}/${cfg.keyFile}";
  };
}
