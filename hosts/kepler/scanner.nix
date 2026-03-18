{
  pkgs,
  user ? "jon",
  ...
}: {
  hardware.sane = {
    enable = true;
    extraBackends = [pkgs.sane-airscan];
    brscan4 = {
      enable = true;
      netDevices = {
        home = {
          model = "DCP-L2640DW";
          ip = "10.9.8.139";
        };
      };
    };
  };
  services.ipp-usb.enable = true;
  users.users."${user}".extraGroups = ["scanner" "lp"];
}
