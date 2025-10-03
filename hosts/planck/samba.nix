let
  # user = "samba";
  photonPath = "/mnt/photon";
  squidPath = "/mnt/squid";

in

{
  services = {

    avahi = {
      enable = true;
      publish.enable = true;
      publish.userServices = true;
      nssmdns4 = true;

      # https://wiki.nixos.org/wiki/Samba#Apple_Time_Machine
      # extraServiceFiles = {
      #   timemachine = ''
      #     <?xml version="1.0" standalone='no'?>
      #     <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
      #     <service-group>
      #       <name replace-wildcards="yes">%h</name>
      #       <service>
      #         <type>_smb._tcp</type>
      #         <port>445</port>
      #       </service>
      #         <service>
      #         <type>_device-info._tcp</type>
      #         <port>0</port>
      #         <txt-record>model=TimeCapsule8,119</txt-record>
      #       </service>
      #       <service>
      #         <type>_adisk._tcp</type>
      #         <txt-record>dk0=adVN=blackhole,adVF=0x82</txt-record>
      #         <txt-record>sys=waMa=0,adVF=0x100</txt-record>
      #       </service>
      #     </service-group>
      #   '';
      # };
    };

    samba = {
      enable = true;
      openFirewall = true;
      settings = {

        global = {
          "workgroup" = "WORKGROUP";
          "server string" = "planck";
          "netbios name" = "planck";
          "security" = "user";
          #"use sendfile" = "yes";
          #"max protocol" = "smb2";
          "hosts allow" = "10.9.8.0/24 10.9.11.0/24 127.0.0.1 localhost";
          "hosts deny" = "0.0.0.0/0";
          "guest account" = "nobody";
          "map to guest" = "bad user";
        };

	jon = {
          "path" = "/home/jon";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
	  "valid users" = "jon";
          "force user" = "jon";
          "force group" = "users";
	};

        public = {
          "path" = "/home/jon/public";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "yes";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "jon";
          "force group" = "users";
        };

        incoming = {
          "path" = "/home/jon/public/incoming";
          "browseable" = "no";
          "read only" = "no";
          "guest ok" = "yes";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "jon";
          "force group" = "users";
        };

        photon = {
          "path" = photonPath;
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
	  "valid users" = "jon";
          "force user" = "jon";
          "force group" = "users";
        };

        squid = {
          "path" = squidPath;
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
	  "valid users" = "jon";
          "force user" = "jon";
          "force group" = "users";
        };
      };
    };

    samba-wsdd = {
      discovery = true;
      enable = true;
      openFirewall = true;
    };

  };

  # Set up password: https://wiki.nixos.org/wiki/Samba#User_Authentication
  # users.users.${user}.isNormalUser = true;

  # Share path must be owned by the respective unix user. (e.g. ❯ chown -R samba: /samba)
  # systemd.tmpfiles.rules = [
  #   "d ${photonPath} 0755 ${user} users"
  #   "d ${squidPath} 0755 ${user} users"
  # ];
}
