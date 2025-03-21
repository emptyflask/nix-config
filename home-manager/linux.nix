{ config, pkgs, lib, ... }:

let

  # all-hies = import (builtins.fetchTarball "https://github.com/infinisil/all-hies/tarball/master") {};
  # ghcide-nix = import (builtins.fetchTarball "https://github.com/cachix/ghcide-nix/tarball/master") {};

  myLocation = "home";
  locations = {
    home = {
      lat = 44.9466;
      long = -93.1517;
    };
  };

  latlong = location:
    if (lib.hasAttrByPath [ location ] locations) then
      locations.${location}
    else
      locations.home;
  background = "$HOME/.config/wallpaper/current";

in {
  fonts.fontconfig.enable = true;

  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.zafiro-icons;
      name = "Zafiro";
    };
    font = {
      name = "Noto Sans 10";
      package = pkgs.noto-fonts;
    };
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
  };

  dconf.enable = false;

  services = {
    blueman-applet.enable = true;

    picom = {
      enable = true;
      fade = true;
      fadeDelta = 5;
      fadeSteps = [ 4.0e-2 4.0e-2 ];
      shadow = false;
      backend = "xrender";
      vSync = true;
      # vSync        = "opengl";
      settings = {
        glx-no-rebind-pixmap = true;
        glx-no-stencil = true;
        # glx-copy-from-front   = false;
        use-damage = true;
        xrender-sync-fence = true;
      };
    };

    gpg-agent = {
      enable = true;
      defaultCacheTtl = (60 * 60 * 4);
      enableSshSupport = true;
    };

    mpd.enable = true;

    redshift = {
      enable = true;
      latitude = toString (latlong myLocation).lat;
      longitude = toString (latlong myLocation).long;
      tray = true;
    };

    screen-locker = {
      enable = false;
      inactiveInterval = 15;
      # lockCmd = ''${pkgs.betterlockscreen}/bin/betterlockscreen -u ${background} -l dimblur'';
      # lockCmd = "${pkgs.i3lock-pixeled}/bin/i3lock-pixeled";
      lockCmd = "${pkgs.i3lock-fancy-rapid}/bin/i3lock-fancy-rapid 8 pixel";
    };

    xscreensaver = {
      enable = true;
      settings = { lock = true; };
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk"; # gnome or gtk
  };

  xdg = {
    enable = true;
    userDirs.enable = true;
  };

  xsession = {
    enable = true;
    initExtra = ''
      ${pkgs.feh}/bin/feh --bg-fill ${background}

      ${pkgs.networkmanagerapplet}/bin/nm-applet &

      ${pkgs.alsa-utils}/bin/amixer -c0 set Headphone 100%,100%
    '';

    windowManager = import ./xmonad/default.nix pkgs;
  };
}
