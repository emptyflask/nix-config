{ inputs, outputs, lib, config, pkgs, ... }:

let rubyVersion = pkgs.ruby;
in
{
  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    config = {
      allowUnfree = true;

      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;

      permittedInsecurePackages =
        lib.optional (pkgs.obsidian.version == "1.5.3") "electron-25.9.0";
    };
  };

  programs = {
    beets = {
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

    broot.enable = true; # directory browser

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    firefox.enable      = true;
    fzf.enable          = true;

    gh = {
      enable = true;
      extensions = with pkgs; [
        gh-cal
        gh-eco
      ];
      settings = {
        aliases = {
          co = "pr checkout";
          pv = "pr view";
        };
        git-protocol = "https";
      };
    };
    gh-dash = {
      enable = true;
    };

    go.enable           = true;
    home-manager.enable = true;
    keychain.enable     = true;
    ncmpcpp.enable      = true;

    yazi = {
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

    zoxide.enable       = true;

    # z-lua = {       # directory quick nav
    #   enable        = true;
    #   enableAliases = true;
    #   options       = ["enhanced" "once" "fzf"];
    # };
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
      "$HOME/.gem/ruby/${rubyVersion.version.libDir}/bin"
    ];
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  imports = [
    (import ./common.nix { inherit pkgs rubyVersion; })
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
