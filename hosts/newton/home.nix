{ pkgs, ... }:

let
  imports = [
    ../home-manager/common.nix
    ../home-manager/environment.nix
    ../home-manager/programs/git
    ../home-manager/programs/kitty
    ../home-manager/programs/neovim
    ../home-manager/programs/tmux
    ../home-manager/programs/vim
    ../home-manager/programs/zathura
    ../home-manager/programs/zsh
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

    packages = with pkgs; [
      alsa-utils
      bmon # network monitor
      burpsuite # network security tool
      bruno # api tool
      cachix
      cheese # webcam photos
      dmenu # minimal desktop menu
      dropbox
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
      wine
      winetricks
      yubioath-flutter
      yubikey-personalization
      zeal # docs (like dash)

      # graphics / print
      ffmpegthumbnailer
      flameshot # screenshots (PrtSc)
      scrot # CLI screenshotter

      # programming - general
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
      eunomia
      f5_6
      fantasque-sans-mono
      ferrum
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

      nerd-fonts.droid-sans-mono
      nerd-fonts.fira-code

      # media
      audacious # music player
      calibre # e-book library
      evince # another PDF viewer
      mplayer
      mpv
      smplayer
      spotify
      vlc
    ];

    sessionPath = [ "$HOME/.gem/ruby/${pkgs.ruby.version.libDir}/bin" ];

    stateVersion = "25.05";
  };

  programs.firefox.enable = true;

  services = {
    gpg-agent = {
      enable = true;
      defaultCacheTtl = (60 * 60 * 4);
      enableSshSupport = true;
    };
  };

  xdg = {
    enable = true;
    userDirs.enable = true;
  };

}
