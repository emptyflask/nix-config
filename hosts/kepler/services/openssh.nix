{ pkgs, lib, system, ... }:

{
  services.fail2ban = {
    enable = true;
    maxretry = 10;
    bantime = "1h";
    bantime-increment = {
      enable = true;
      multipliers = "1 2 4 8 16 32 64 128 256";
      maxtime = "168h"; # 7 days
      overalljails = true;
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      AllowUsers = [ "jon" ];
      KbdInteractiveAuthentication = true;
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = false;
    };
  };

}
