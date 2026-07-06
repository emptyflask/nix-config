{
  inputs,
  pkgs,
  config,
  ...
}: let
  # Define ls aliases only if eza is not enabled
  lsAliases =
    if (!config.programs.eza.enable)
    then {
      l = "ls -alh";
      ll = "ls -l";
      ls = "ls --color -F";
    }
    else {};

  unstable =
    inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in {
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    enableCompletion = true;
    defaultKeymap = "viins";
    history = {
      extended = true;
      size = 50000;
    };

    initContent =
      (builtins.readFile ./zshrc)
      + ''
        eval "$(${pkgs.fasd}/bin/fasd --init auto)"
      '';

    shellAliases =
      lsAliases
      // {
        be = "bundle exec";
        bi = "bundle install";
        bu = "bundle update";

        # pngcrush with default settings
        crush = "${pkgs.pngcrush}/bin/pngcrush -d crushed -rem gAMA -rem cHRM -rem iCCP -rem sRGB";

        curl_json = ''curl -v -H "Content-Type: application/json"'';
        duh = "du -csh";
        gg = "${pkgs.gitui}/bin/gitui";
        grep = "grep --color=auto";

        # image output in kitty terminal
        icat = "${pkgs.kitty}/bin/kitty +kitten icat";

        j = ''
          ${unstable.jira-cli-go}/bin/jira issue list -sopen -s"In Review" -a"jon@sxsw.com"'';
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
      {
        name = "nix-zsh-completions";
        src = pkgs.nix-zsh-completions;
      }
      {
        name = "zsh-completions";
        src = pkgs.zsh-completions;
      }
      {
        name = "fast-syntax-highlighting";
        src = pkgs.zsh-fast-syntax-highlighting;
      }
      {
        name = "zsh-nix-shell";
        src = pkgs.zsh-nix-shell;
        file = "${pkgs.zsh-nix-shell}/nix-shell.plugin.zsh";
      }
    ];
  };
}
