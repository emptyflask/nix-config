{
  config,
  inputs,
  lib,
  pkgs,
  self,
  ...
}: let
  location = import "${self}/home-manager/locations/oakwood.nix";

  background = "$HOME/.config/wallpaper/current";
in {
  imports = [
    "${self}/home-manager/claude.nix"
    "${self}/home-manager/common.nix"
    "${self}/home-manager/environment.nix"
    "${self}/home-manager/services/dunst"
    "${self}/home-manager/services/mpd"
    "${self}/home-manager/services/trayer"
    "${self}/home-manager/programs/alacritty"
    "${self}/home-manager/programs/git"
    "${self}/home-manager/programs/kitty"
    "${self}/home-manager/programs/wezterm"
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

  age.identityPaths = ["/home/jon/.ssh/id_agenix"];
  age.secretsDir = "/run/user/1000/agenix";
  age.secrets.ghi-token.file = "${self}/secrets/ghi-token.age";
  age.secrets.jira-token.file = "${self}/secrets/jira-token.age";
  age.secrets.nix-access-tokens.file = "${self}/secrets/nix-access-tokens.age";

  programs.git.settings.ghi.token = "!${pkgs.coreutils}/bin/cat ${config.age.secrets.ghi-token.path}";

  programs.zsh.initContent = lib.mkAfter ''
    export JIRA_API_TOKEN="$(${pkgs.coreutils}/bin/cat ${config.age.secrets.jira-token.path} 2>/dev/null)"
  '';

  nix.extraOptions = "!include ${config.age.secrets.nix-access-tokens.path}\n";

  programs.zsh.shellAliases = {
    deploy-kepler = "nh os switch";
    deploy-newton = "nh os switch -H newton --target-host jon@newton.lan -e passwordless";
    deploy-planck = "nh os switch -H planck --target-host jon@planck.lan -e passwordless";
  };

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
    gtk4.theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
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
      inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default # agenix cli tool

      cachix

      # ghcide-nix.ghcide-ghc865

      # _1password
      # _1password-gui
      alsa-utils
      awscli2
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
      proton-pass
      proton-vpn
      pv # pipe viewer
      qalculate-gtk # calculator
      qemu
      scowl # spellchecker / dictionary
      sone # tidal gui
      st
      (thunar.override {
        thunarPlugins = with pkgs; [
          thunar-volman
          thunar-archive-plugin
        ];
      })
      vbindiff # Visual Binary Diff
      whois
      wireguard-tools
      xdg-utils
      xfconf
      xfce4-exo
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
      telegram-desktop
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
      vista-fonts

      # graphics / print
      gimp
      imagemagick
      inkscape
      krita

      # media
      # handbrake           # dvd ripper
      audacious # music player
      calibre # e-book library
      evince # another PDF viewer
      filebot # media renamer
      mpc
      mplayer
      mpv
      ncmpcpp
      rmpc # rusty music player client
      smplayer
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
      nixfmt # format nix
      shellcheck # shell script analyzer
      sourceHighlight
      strace # system call trace
      tig # git tui frontend
      uncrustify # format c/c++/c#/java/etc
      # universal-ctags
      vscode

      # programming - nix
      alejandra # format nix

      # programming - elixir / erlang
      beamPackages.elixir

      # programming - javascript
      biome
      diagnostic-languageserver
      nodejs
      typescript
      typescript-language-server

      # programming - haskell
      # ghc
      # cabal2nix
      # cabal-install
      haskellPackages.ghcid
      haskellPackages.haskell-language-server
      haskellPackages.hlint
      haskellPackages.stylish-haskell
      # ormolu
      # stack

      # programming - python
      python3Packages.pynvim # for neovim

      # programming - ruby
      bundix
      # jekyll
      ruby
      ruby.gems.pry

      # programming - rust
      cargo
      rustc
      rustfmt
    ];

    pointerCursor = {
      enable = true;
      package = pkgs.gnome-themes-extra;
      size = 16; # default = 32; example = 64;
      name = "Adwaita";
      x11 = {
        enable = true;
        defaultCursor = "left_ptr"; # example = "X_cursor";
      };
    };

    sessionPath = ["$HOME/.gem/ruby/${pkgs.ruby.version.libDir}/bin"];

    stateVersion = "21.05";
  };

  programs.nix-index.enableZshIntegration = true;

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
      plugins = ["fetchart" "lastgenre" "lyrics" "web"];
      ui = {color = "yes";};
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

  programs.firefox = {
    enable = true;
    configPath = "${config.xdg.configHome}/mozilla/firefox";
    # Trust the OS cert store (incl. mkcert's rootCA.pem, wired in via
    # security.pki.certificateFiles) instead of Firefox's own NSS store.
    policies.Certificates.ImportEnterpriseRoots = true;
  };

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
    extensions = with pkgs; [gh-cal gh-eco];
    settings = {
      aliases = {
        co = "pr checkout";
        pv = "pr view";
      };
      git-protocol = "https";
    };
  };
  programs.gh-dash = {enable = true;};

  programs.go.enable = true;
  programs.keychain = {
    enable = true;
    keys = ["id_rsa" "id_ed25519"];
  };

  programs.ncmpcpp = {
    bindings = [];
    enable = true;
    settings = let
      nowPlaying = pkgs.writeShellScript "now-playing-notify" ''
        readarray -t info < <(${pkgs.mpc}/bin/mpc --format '%title%\n%artist%\n%album%' current | head -n 3)
        title=''${info[0]}
        artist=''${info[1]}
        album=''${info[2]}
        ${pkgs.dunst}/bin/dunstify -a "Now Playing" "$title" "$artist\n$album" -t 4000
      '';
    in {execute_on_song_change = "${nowPlaying}";};
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };

  services = {
    blueman-applet.enable = true;

    gpg-agent = {
      enable = true;
      defaultCacheTtl = 60 * 60 * 4;
      enableSshSupport = true;
    };

    mpd.enable = true;

    picom = {
      enable = true;
      fade = true;
      fadeDelta = 5;
      fadeSteps = [4.0e-2 4.0e-2];
      shadow = false;
      backend = "glx";
      vSync = false;
      settings = {
        use-damage = true;
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
      settings = {lock = true;};
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  xdg = {
    enable = true;
    userDirs.enable = true;
    userDirs.setSessionVariables = false;

    # xdg-desktop-portal-lxqt doesn't implement the Screenshot portal, so
    # flameshot (since v14) hangs 30s trying it before failing. Skip the
    # portal and use Qt's native X11 capture directly.
    configFile."flameshot/flameshot.ini" = {
      force = true; # flameshot rewrites this file itself; don't fight it
      text = ''
        [General]
        contrastOpacity=188
        disabledTrayIcon=false
        drawColor=#ff0000
        drawThickness=6
        fontFamily=Fira Sans Medium
        savePath=/home/jon/Downloads/images
        savePathFixed=false
        showStartupLaunchMessage=true
        startupLaunch=false
        useX11LegacyScreenshot=true

        [Shortcuts]
        TYPE_ARROW=A
        TYPE_CIRCLE=C
        TYPE_CIRCLECOUNT=
        TYPE_COMMIT_CURRENT_TOOL=Ctrl+Return
        TYPE_COPY=Ctrl+C
        TYPE_DELETE_CURRENT_TOOL=Del
        TYPE_DRAWER=D
        TYPE_EXIT=Ctrl+Q
        TYPE_MARKER=M
        TYPE_MOVESELECTION=Ctrl+M
        TYPE_MOVE_DOWN=Down
        TYPE_MOVE_LEFT=Left
        TYPE_MOVE_RIGHT=Right
        TYPE_MOVE_UP=Up
        TYPE_OPEN_APP=Ctrl+O
        TYPE_PENCIL=P
        TYPE_PIN=
        TYPE_PIXELATE=B
        TYPE_RECTANGLE=R
        TYPE_REDO=Ctrl+Shift+Z
        TYPE_RESIZE_DOWN=Shift+Down
        TYPE_RESIZE_LEFT=Shift+Left
        TYPE_RESIZE_RIGHT=Shift+Right
        TYPE_RESIZE_UP=Shift+Up
        TYPE_SAVE=Ctrl+S
        TYPE_SELECTION=S
        TYPE_SELECT_ALL=Ctrl+A
        TYPE_TEXT=T
        TYPE_TOGGLE_PANEL=Space
        TYPE_UNDO=Ctrl+Z
      '';
    };
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
