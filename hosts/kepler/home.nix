{ inputs, lib, pkgs, self, ... }:

let
  location = import "${self}/home-manager/locations/oakwood.nix";

  background = "$HOME/.config/wallpaper/current";

in {
  imports = [
    "${self}/home-manager/common.nix"
    "${self}/home-manager/environment.nix"
    "${self}/home-manager/accounts"
    "${self}/home-manager/services/dunst"
    "${self}/home-manager/services/mpd"
    "${self}/home-manager/services/spotifyd"
    "${self}/home-manager/services/trayer"
    "${self}/home-manager/programs/alacritty"
    "${self}/home-manager/programs/git"
    "${self}/home-manager/programs/kitty"
    "${self}/home-manager/programs/neomutt"
    "${self}/home-manager/programs/neovim"
    "${self}/home-manager/programs/rofi"
    "${self}/home-manager/programs/starship"
    "${self}/home-manager/programs/tmux"
    "${self}/home-manager/programs/vim"
    "${self}/home-manager/programs/yazi"
    "${self}/home-manager/programs/zathura"
    "${self}/home-manager/programs/zsh"
    "${self}/home-manager/xmobar"
    "${self}/home-manager/xresources"
  ];

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
      ".ghci".source = "${self}/home-manager/home/ghci";
      ".psqlrc".source = "${self}/home-manager/home/psqlrc";
      ".railsrc".source = "${self}/home-manager/home/railsrc";
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
      httpie
      jmtpfs # Media Transfer Protocol (usb device filesystems)
      joplin-desktop # notes
      keybase
      keybase-gui
      kitty # terminal
      libreoffice
      lxmenu-data # installed apps
      lynx # text web browser
      miller # csv tool
      obsidian # note taking
      pandoc # document converter
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
      font-awesome
      font-awesome_5
      font-awesome_6
      helvetica-neue-lt-std
      hermit
      ibm-plex
      inconsolata
      jetbrains-mono
      league-of-moveable-type
      liberation_ttf
      libre-baskerville
      libre-bodoni
      libre-caslon
      libre-franklin
      medio
      national-park-typeface
      nerd-fonts.droid-sans-mono
      nerd-fonts.fira-code
      norwester-font
      penna
      route159
      seshat
      tenderness
      vegur
      vistafonts

      # graphics / print
      imagemagick
      inkscape

      # media
      # handbrake           # dvd ripper
      audacious # music player
      calibre # e-book library
      evince # another PDF viewer
      mpc_cli
      mplayer
      mpv
      ncmpcpp
      smplayer
      spotify
      vlc

      # programming - general
      android-studio
      dbeaver-bin # DB GUI
      docker-compose
      exercism
      foreman
      gcc
      gitui # git tui frontend
      gnumake
      hexyl
      html-tidy # format html
      lazydocker
      ltrace # lib trace
      niv # nix channel config
      nixfmt-classic # format nix
      shellcheck # shell script analyzer
      sourceHighlight
      strace # system call trace
      tig # git tui frontend
      uncrustify # format c/c++/c#/java/etc
      universal-ctags
      vscode

      # programming - nix
      alejandra # format nix

      # programming - elixir / erlang
      elixir

      # programming - javascript
      biome
      nodejs
      nodePackages.diagnostic-languageserver
      nodePackages.eslint_d
      nodePackages.typescript
      nodePackages.typescript-language-server

      # programming - haskell
      ghc
      cabal2nix
      cabal-install
      haskellPackages.apply-refact
      haskellPackages.ghcid
      haskellPackages.haskell-language-server
      haskellPackages.hlint
      haskellPackages.stylish-haskell
      haskellPackages.yesod
      ormolu
      stack

      # programming - python
      python3Packages.pynvim # for neovim

      # programming - ruby
      bundix
      jekyll
      ruby
      ruby.gems.pry

      # programming - rust
      cargo
      rustc
      rustfmt

      # chat / email
      neomutt # CLI mail
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

  programs.broot.enable = true; # directory browser

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

  programs.gh = {
    enable = true;
    extensions = with pkgs; [ gh-cal gh-eco ];
    settings = {
      aliases = {
        co = "pr checkout";
        pv = "pr view";
      };
      git-protocol = "https";
    };
  };
  programs.gh-dash = { enable = true; };

  programs.go.enable = true;
  programs.keychain.enable = true;

  programs.ncmpcpp = {
    bindings = [ ];
    enable = true;
    settings = let
      nowPlaying = pkgs.writeShellScript "now-playing-notify" ''
      readarray -t info < <(${pkgs.mpc_cli}/bin/mpc --format '%title%\n%artist%\n%album%' current | head -n 3)
      title=''${info[0]}
      artist=''${info[1]}
      album=''${info[2]}
      ${pkgs.dunst}/bin/dunstify -a "Now Playing" "$title" "$artist\n$album" -t 4000
      '';
    in { execute_on_song_change = "${nowPlaying}"; };
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
      latitude = toString location.lat;
      longitude = toString location.lon;
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

    windowManager = import "${self}/home-manager/xmonad/default.nix" pkgs;
  };
}
