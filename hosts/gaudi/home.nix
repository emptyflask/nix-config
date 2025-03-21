{ lib, config, pkgs, nixpkgs, ... }:

let
  hm = path: "${../../home-manager}/${path}";

  imports = [
    (hm "common.nix")
    (hm "programs/git")
    (hm "programs/kitty")
    (hm "programs/neomutt")
    (hm "programs/neovim")
    (hm "programs/tmux")
    (hm "programs/vim")
    (hm "programs/zathura")
    (hm "programs/zsh")
  ];
in {
  inherit imports;

  home = {
    username = "jonroberts";
    homeDirectory = "/Users/jonroberts";
    file = {
      ".ghci".source = ../../home-manager/home/ghci;
      ".psqlrc".source = ../../home-manager/home/psqlrc;
      ".railsrc".source = ../../home-manager/home/railsrc;
    };

    packages = with pkgs; [
      zlib
      # nixFlakes
    ];

    sessionPath = [
      "$HOME/.gem/ruby/${pkgs.ruby.version.libDir}/bin"
    ];
  };

 home.stateVersion = "23.11";
}
