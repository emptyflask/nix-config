{
  services.displayManager.defaultSession = "none+xmonad";

  services.xserver = {
    enable = true;

    xkb = {
      layout = "us";
      variant = "altgr-intl";
      options = "compose:sclk";
    };

    # Enable touchpad support.
    # libinput.enable = true;

    videoDrivers = [ "nvidia" ];

    displayManager = {
      lightdm.greeters.gtk = {
        enable = true;
        # user = "jon";
        # extraConfig = ''
        #   [greeter]
        #   show-password-label = false
        #   [greeter-theme]
        #   background-image = ""
        # '';
      };
    };

    windowManager.xmonad.enable = true;

    screenSection = ''
      Option "metamodes" "nvidia-auto-select +0+0 { ForceFullCompositionPipeline = On }"
      Option "AllowIndirectGLXProtocol" "off"
      Option "TripleBuffer" "on"
    '';

  };
}
