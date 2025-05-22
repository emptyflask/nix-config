{ lib, pkgs, ... }:

let
  hm = path: "${../../home-manager}/${path}";
  imports = [
    (hm "common.nix")
    (hm "environment.nix")
    (hm "accounts")
    (hm "services/dunst")
    (hm "services/mpd")
    (hm "services/spotifyd")
    (hm "services/trayer")
    (hm "programs/alacritty")
    (hm "programs/git")
    (hm "programs/kitty")
    (hm "programs/neomutt")
    (hm "programs/neovim")
    (hm "programs/rofi")
    (hm "programs/starship")
    (hm "programs/tmux")
    (hm "programs/vim")
    (hm "programs/yazi")
    (hm "programs/zathura")
    (hm "programs/zsh")
    (hm "xmobar")
    (hm "xresources")
  ];

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
  inherit imports;

  dconf.enable = false;

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

  home = {
    username = "jon";
    homeDirectory = "/home/jon";

    file = {
      ".ghci".source = (hm "home/ghci");
      ".psqlrc".source = (hm "home/psqlrc");
      ".railsrc".source = (hm "home/railsrc");
    };

    keyboard = {
      layout = "us";
      variant = "altgr-intl";
    };

    packages = with pkgs; [
      cachix

      # ghcide-nix.ghcide-ghc865

      # _1password
      # _1password-gui
      alsa-utils
      bmon # network monitor
      # burpsuite  # network security tool
      bruno # api tool
      cheese # webcam photos
      dmenu # minimal desktop menu
      dropbox
      # exodus     # crypto wallet
      # gnome.gnome-calendar
      # gnome.gnome-control-center
      exiftool
      glow # markdown viewer
      google-chrome
      jmtpfs # Media Transfer Protocol (usb device filesystems)
      joplin-desktop # notes
      keybase
      keybase-gui
      kitty # terminal
      libreoffice
      lxmenu-data # installed apps
      lynx # text web browser
      miller # csv tool
      pavucontrol
      postman
      protonvpn-cli
      qalculate-gtk # calculator
      qemu
      scowl # spellchecker / dictionary
      st
      xdg-utils
      whois
      (xfce.thunar.override {
        thunarPlugins = with pkgs; [
          xfce.thunar-volman
          xfce.thunar-archive-plugin
        ];
      })
      xfce.xfconf
      xfce.exo
      yubioath-flutter
      yubikey-personalization
      zeal # docs (like dash)

      # games
      # steam-run
      # unityhub
      # lutris
      # minigalaxy
      wine
      winetricks

      # graphics / print
      # adobe-reader
      # blender
      # darktable
      ffmpegthumbnailer
      flameshot # screenshots (PrtSc)
      # gimp-with-plugins
      # krita
      # meshlab
      # scribus             # page layout
      scrot # CLI screenshotter

      # programming - general
      android-studio
      dbeaver-bin # DB GUI
      docker-compose
      gcc
      hexyl
      lazydocker
      ltrace # lib trace
      strace # system call trace
      vscode
      nixfmt-classic # format nix
      uncrustify # format c/c++/c#/java/etc

      # programming - haskell
      haskellPackages.stylish-haskell
      ormolu
      stack

      # programming - nix
      alejandra # format nix

      # chat / email
      discord
      protonmail-bridge
      signal-desktop
      slack
      thunderbird-bin
      zoom-us

      # fonts
      aileron
      caladea # free cambria
      carlito # free calibri
      comfortaa
      dejavu_fonts
      eunomia
      f5_6
      fantasque-sans-mono
      ferrum
      fira
      fira-code-symbols
      font-awesome_5
      font-awesome_6
      helvetica-neue-lt-std
      hermit
      ibm-plex
      inconsolata
      league-of-moveable-type
      liberation_ttf
      libre-baskerville
      libre-bodoni
      libre-caslon
      libre-franklin
      medio
      national-park-typeface
      norwester-font
      penna
      route159
      seshat
      tenderness
      vegur
      vistafonts

      (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
      # nerd-fonts.droid-sans-mono
      # nerd-fonts.fira-code

      # media
      audacious # music player
      calibre # e-book library
      evince # another PDF viewer
      # handbrake           # dvd ripper
      mplayer
      mpv
      smplayer
      spotify
      vlc
    ];

    pointerCursor = {
      package = pkgs.gnome-themes-extra;
      size = 16; # default = 32; example = 64;
      name = "Adwaita";
      x11 = {
        enable = true;
        defaultCursor = "left_ptr"; # example = "X_cursor";
      };
    };

    sessionPath = [ "$HOME/.gem/ruby/${pkgs.ruby.version.libDir}/bin" ];

    stateVersion = "21.05";
  };

  programs.beets = {
    enable = true;
    mpdIntegration.enableStats = true;
    mpdIntegration.enableUpdate = true;
    settings = {
      directory = "/media/repository/music";
      library = "/media/repository/music/library.db";
      import = {
        copy = "no";
        move = "yes";
        write = "yes";
      };
      paths = {
        default = "$albumartist/$album/$track $title";
        singleton = "Singles/$artist - $title";
        comp = "Compilations/$album/$track $title";
        "albumtype:soundtrack" = "Soundtracks/$album/$track $title";
      };
      plugins = [ "fetchart" "lastgenre" "lyrics" "web" ];
      ui = { color = "yes"; };
      wlg = {
        auto = "yes";
        force = "no";
      };
    };
  };

  programs.eza = {
    enable = true;
    git = true;
    icons = "auto";
  };
  programs.firefox.enable = true;
  programs.ncspot = {
    enable = true;
    settings = {
      initial_screen = "library";
      notify = true;
      use_nerd_font = true;
      shuffle = false;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk"; # gnome or gtk
  };

  services = {
    blueman-applet.enable = true;

    gpg-agent = {
      enable = true;
      defaultCacheTtl = (60 * 60 * 4);
      enableSshSupport = true;
    };

    mpd.enable = true;

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

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

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

    windowManager = import (hm "xmonad/default.nix") pkgs;
  };
}
