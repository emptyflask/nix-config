{ outputs, pkgs, ... }:

{
  nixpkgs = {
    overlays = [ outputs.overlays.additions outputs.overlays.modifications ];
    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  programs = {
    broot.enable = true; # directory browser

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    fzf.enable = true;

    gh = {
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
    gh-dash = { enable = true; };

    go.enable = true;
    home-manager.enable = true;
    keychain.enable = true;
    ncmpcpp = {
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

    zoxide.enable = true;
  };

  home.packages = with pkgs; [
    bat # cat clone with syntax highlighting and git integration
    bc # cli calculator
    du-dust # rust modern clone of du
    fd # find entries in filesystem
    fortune
    htop
    httpie
    jq
    killall
    magic-wormhole # simple secure file transfer
    mosh # ssh alternative
    nix-index
    nix-prefetch-git
    nix-zsh-completions
    obsidian # note taking
    parallel # run commands in parallel
    pandoc # document converter
    ranger # CLI file manager
    ripgrep
    ripgrep-all
    shared-mime-info # recognize file types
    tealdeer # tldr for various shell tools
    translate-shell
    units
    # xarchiver

    # graphics / print
    imagemagick
    inkscape

    # programming - general
    exercism
    foreman
    gitui # git tui frontend
    gnumake
    html-tidy # format html
    niv # nix channel config
    sourceHighlight
    shellcheck # shell script analyzer
    tig # git tui frontend
    universal-ctags

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
    haskellPackages.yesod

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
    # protonmail-bridge
    # weechat.override
    # {
    #   configure = { ... }: {
    #     scripts = with pkgs.weechatScripts; [
    #       emoji
    #       autosort
    #       confversion
    #       listbuffer
    #       weechat-matrix
    #       weechat-grep
    #     ];
    #     init = ''
    #       /set irc.server_default.username "jon"
    #       /set irc.server_default.realname "Jon"
    #       /set irc.server_default.nicks "emptyflask,emptyfl4sk"
    #
    #       /secure passphrase "xxxxxx"
    #       /secure set libera_password "xxxxx"
    #       /secure set freenode_password "xxxxx"
    #
    #       /server add libera irc.libera.chat/6697 -tls
    #       /set irc.server.libera.sasl_username "emptyflask"
    #       /set irc.server.libera.sasl_password "$''${sec.data.libera_password}"
    #       /set irc.server.libera.autoconnect on
    #
    #       /set irc.server.freenode.autojoin = "#nixos,#ruby,#haskell"
    #     '';
    #   };
    # }
    #
    # fonts
    fira
    fira-code
    fira-code-symbols
    font-awesome
    jetbrains-mono

    # media
    mpc_cli
    ncmpcpp
  ];

}
