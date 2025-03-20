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
    ../home-manager/xresources
  ];

in {
  inherit imports;

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

  home = {
    username = "jon";
    homeDirectory = "/home/jon";
    file = {
      ".ghci".source = ../home-manager/home/ghci;
      ".psqlrc".source = ../home-manager/home/psqlrc;
      ".railsrc".source = ../home-manager/home/railsrc;
    };
    sessionPath = [ "$HOME/.gem/ruby/${pkgs.ruby.version.libDir}/bin" ];
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  home.stateVersion = "21.05";
}
