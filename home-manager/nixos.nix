{ inputs, outputs, lib, config, pkgs, ... }:

let rubyVersion = pkgs.ruby_3_3;
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

    z-lua = {       # directory quick nav
      enable        = true;
      enableAliases = true;
      options       = ["enhanced" "once" "fzf"];
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
