{ pkgs, ... }:

let
  imports = [
    ../home-manager/common.nix
    ../home-manager/linux.nix
    ../home-manager/environment.nix
    ../home-manager/accounts
    ../home-manager/services/dunst
    ../home-manager/services/mpd
    ../home-manager/services/spotifyd
    ../home-manager/services/trayer
    ../home-manager/programs/alacritty
    ../home-manager/programs/git
    ../home-manager/programs/kitty
    ../home-manager/programs/neomutt
    ../home-manager/programs/neovim
    ../home-manager/programs/rofi
    ../home-manager/programs/tmux
    ../home-manager/programs/vim
    ../home-manager/programs/yazi
    ../home-manager/programs/zathura
    ../home-manager/programs/zsh
    ../home-manager/xmobar
    ../home-manager/xresources
  ];

in {
  inherit imports;

  home = {
    username = "jon";
    homeDirectory = "/home/jon";

    file = {
      ".ghci".source = ../home-manager/home/ghci;
      ".psqlrc".source = ../home-manager/home/psqlrc;
      ".railsrc".source = ../home-manager/home/railsrc;
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
        default = "$genre/$albumartist/$album/$track $title";
        singleton = "Singles/$artist - $title";
        comp = "$genre/$album/$track $title";
        "albumtype:soundtrack" = "Soundtracks/$album/$track $title";
      };
      plugins =
        [ "fetchart" "lastgenre" "lyrics" "mpdstats" "mpdupdate" "web" ];
      ui = { color = "yes"; };
      wlg = {
        auto = "yes";
        force = "no";
      };
    };
  };

  programs.firefox.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
