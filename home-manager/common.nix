{ outputs, pkgs, ... }:

{
  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
    ];
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

    zoxide.enable       = true;
  };

  home.packages = with pkgs; [
    bat                 # cat clone with syntax highlighting and git integration
    bc                  # cli calculator
    du-dust             # rust modern clone of du
    fd                  # find entries in filesystem
    fortune
    htop
    httpie
    jq
    killall
    magic-wormhole      # simple secure file transfer
    mosh                # ssh alternative
    nix-index
    nix-prefetch-git
    nix-zsh-completions
    obsidian            # note taking
    pandoc              # document converter
    ranger              # CLI file manager
    ripgrep
    shared-mime-info    # recognize file types
    tealdeer            # tldr for various shell tools
    translate-shell
    units
    # xarchiver

    # graphics / print
    imagemagick
    inkscape

    # programming - general
    exercism
    foreman
    gnumake
    html-tidy           # format html
    niv                 # nix channel config
    sourceHighlight
    shellcheck          # shell script analyzer
    tig                 # git tui frontend
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
    neomutt             # CLI mail
    # protonmail-bridge
    weechat

    # fonts
    fira
    fira-code
    fira-code-symbols
    font-awesome
    jetbrains-mono

    # media
    ncmpcpp
  ];

}
