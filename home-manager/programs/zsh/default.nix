{ pkgs, config, ... }:

let
  lscolors = builtins.fetchGit {
    url = "https://github.com/trapd00r/LS_COLORS.git";
    ref = "master";
  };

  chruby = false;
  source_chruby = if builtins.isAttrs chruby then ''
    source ${chruby}/share/chruby/chruby.sh
    source ${chruby}/share/chruby/auto.sh
  '' else
    "";

  # Define ls aliases only if eza is not enabled
  lsAliases = if (!config.programs.eza.enable) then {
    l = "ls -alh";
    ll = "ls -l";
    ls = "ls --color -F";
  } else
    { };

in {
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    defaultKeymap = "viins";
    history = {
      extended = true;
      size = 50000;
    };

    initContent = (builtins.readFile ./zshrc) + source_chruby + ''
      source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
      eval "$(${pkgs.fasd}/bin/fasd --init auto)"
      eval $(${pkgs.coreutils}/bin/dircolors -b ${lscolors}/LS_COLORS)
    '';

    shellAliases = lsAliases // {
      be = "bundle exec";
      bi = "bundle install";
      bu = "bundle update";

      # pngcrush with default settings
      crush =
        "${pkgs.pngcrush}/bin/pngcrush -d crushed -rem gAMA -rem cHRM -rem iCCP -rem sRGB";

      curl_json = ''curl -v -H "Content-Type: application/json"'';
      duh = "du -csh";
      gg = "${pkgs.gitui}/bin/gitui";
      grep = "grep --color=auto";

      # image output in kitty terminal
      icat = "kitty +kitten icat";

      j = "jira ls -a emptyflask";
      json = "jq '.' -C | less";

      m = "ncmpcpp";

      nixgc = "nix-collect-garbage -d";
      nixq = "nix-env -qaP";
      nixrm = "nix-env -q | fzf | xargs -I{} nix-env -e {}";
      nixup = "nix-env -u";
      nixupgrade = ''nix-channel --update && nix-env -u \"*\"'';

      # open = "xdg-open";

      tailf = "tail -f";
      trs = "touch tmp/restart.txt";
    };

    sessionVariables = {
      FZF_DEFAULT_COMMAND = "${pkgs.ripgrep}/bin/rg --files";

      FZF_DEFAULT_OPTS = ''
        --color=bg+:#3c3836,bg:#1d2021,spinner:#8ec07c,hl:#83a598
        --color=fg:#bdae93,header:#83a598,info:#fabd2f,pointer:#8ec07c
        --color=marker:#8ec07c,fg+:#ebdbb2,prompt:#fabd2f,hl+:#83a598
      '';

      FZF_ALT_C_OPTS = "--preview '${pkgs.tree}/bin/tree -C {} | head -100'";

      FZF_CTRL_T_OPTS = ''
        --preview '[[ \$(${pkgs.file}/bin/file --mime {}) =~ binary ]] &&
          echo {} is a binary file ||
          (bat --style=numbers --color=always {} ||
          cat {}) 2> /dev/null | head -100'
      '';

      WORDCHARS = "*?[]~&;!$%^<>";
    };

    plugins = [
      # {
      #   name = "blox";
      #   src = builtins.fetchGit {
      #     url = "https://github.com/yardnsm/blox-zsh-theme.git";
      #     ref = "master";
      #   };
      # }

      {
        name = "fast-syntax-highlighting";
        src = builtins.fetchGit {
          url =
            "https://github.com/zdharma-continuum/fast-syntax-highlighting.git";
          ref = "refs/tags/v1.55";
        };
      }

      {
        name = "zsh-256color";
        src = builtins.fetchGit {
          url = "https://github.com/chrissicool/zsh-256color.git";
          ref = "master";
        };
      }

      {
        name = "zsh-completions";
        src = builtins.fetchGit {
          url = "https://github.com/zsh-users/zsh-completions.git";
          ref = "master";
        };
      }

      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.5.0";
          sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
        };
      }
    ];

  };
}
