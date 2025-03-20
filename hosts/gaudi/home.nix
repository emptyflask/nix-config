{ lib, config, pkgs, nixpkgs, ... }:

{
  home = {
    username = "jonroberts";
    homeDirectory = "/Users/jonroberts";
    file = {
      ".ghci".source = ../home-manager/home/ghci;
      ".psqlrc".source = ../home-manager/home/psqlrc;
      ".railsrc".source = ../home-manager/home/railsrc;
    };

    packages = with pkgs; [
      zlib
      # nixFlakes
    ];

    sessionPath = [
      "$HOME/.gem/ruby/${pkgs.ruby.version.libDir}/bin"
    ];
  };

 imports = [
    ../home-manager/common.nix
    ../home-manager/programs/git
    ../home-manager/programs/kitty
    ../home-manager/programs/neomutt
    ../home-manager/programs/neovim
    ../home-manager/programs/tmux
    ../home-manager/programs/vim
    ../home-manager/programs/zathura
    ../home-manager/programs/zsh
 ];

 home.stateVersion = "23.11";
}
