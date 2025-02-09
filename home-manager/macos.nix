{ lib, config, pkgs, nixpkgs, ... }:

{
  home = {
    username = "jonroberts";
    homeDirectory = "/Users/jonroberts";
    file = {
      ".ghci".source = ./nixos/home/ghci;
      ".psqlrc".source = ./nixos/home/psqlrc;
      ".railsrc".source = ./nixos/home/railsrc;
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
    ./common.nix
    ./nixos/programs/git
    ./nixos/programs/kitty
    ./nixos/programs/neomutt
    ./nixos/programs/neovim
    ./nixos/programs/tmux
    ./nixos/programs/vim
    ./nixos/programs/zathura
    ./nixos/programs/zsh
 ];

 home.stateVersion = "23.11";
}
