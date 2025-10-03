{pkgs, lib, system, ...}:

{
  services = {
    nzbget = {
      enable = true;
      user = "usenet";
      group = "usenet";
    };

    sabnzbd = {
      enable = true;
      user = "usenet";
      group = "usenet";
    };
  };
}
