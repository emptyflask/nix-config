{ inputs, outputs, lib, config, pkgs, ... }:

{
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
        plugins = [
          "fetchart"
          "lastgenre"
          "lyrics"
          "mpdstats"
          "mpdupdate"
          "web"
        ];
        ui = {
          color = "yes";
        };
        wlg = {
          auto = "yes";
          force = "no";
        };
      };
  };

  programs.firefox.enable      = true;

programs.yazi = {
      enable         = true;
      # plugins = {
      #   hexyl = builtins.fetchGit {
      #     url = "https://github.com/Reledia/hexyl.yazi";
      #     ref = "main";
      #   };
      #   glow = builtins.fetchGit {
      #     url = "https://github.com/Reledia/glow.yazi";
      #     ref = "main";
      #   };
      #   miller = builtins.fetchGit {
      #     url = "https://github.com/Reledia/miller.yazi";
      #     ref = "main";
      #   };
      # };
      settings = {
        manager = {
          sort_by = "natural";
          sort_reverse = false;
          sort_dir_first = true;
          show_hidden = false;
          show_symlink = true;
        };
        opener = {
          audio = [{
            run = "${pkgs.audacious}/bin/audacious \"$@\"";
            orphan = true;
          }];
          video = [{
            run = "${pkgs.mplayer}/bin/mplayer \"$@\"";
            orphan = true;
          }];
        };
        open = {
          prepend_rules = [
            { mime = "audio/*"; use = "audio"; }
            { mime = "video/*"; use = "video"; }
          ];
        };
        plugin = {
          prepend_previewers = [
            { name = "*.md"; run = "glow"; }
            { mime = "text/csv"; run = "miller"; }
          ];
          append_previewers = [
            { name = "*"; run = "hexyl"; }
          ];
        };
      };
    };

  home = {
    username = "jon";
    homeDirectory = "/home/jon";
    file = {
      ".ghci".source = ./nixos/home/ghci;
      ".psqlrc".source = ./nixos/home/psqlrc;
      ".railsrc".source = ./nixos/home/railsrc;
    };
    sessionPath = [
      "$HOME/.gem/ruby/${pkgs.ruby.version.libDir}/bin"
    ];
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  imports = [
    ./common.nix
    ./nixos/linux.nix
    ./nixos/environment.nix
    ./nixos/accounts
    ./nixos/services/dunst
    ./nixos/services/mpd
    ./nixos/services/spotifyd
    ./nixos/services/trayer
    ./nixos/programs/alacritty
    ./nixos/programs/git
    ./nixos/programs/kitty
    ./nixos/programs/neomutt
    ./nixos/programs/neovim
    ./nixos/programs/rofi
    # ./programs/st
    ./nixos/programs/tmux
    ./nixos/programs/vim
    ./nixos/programs/zathura
    ./nixos/programs/zsh
    ./nixos/xresources
  ];

  home.stateVersion = "21.05";
}
