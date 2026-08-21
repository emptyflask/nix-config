{
  inputs,
  lib,
  pkgs,
  self,
  ...
}: let
  imports = [
    "${self}/home-manager/environment.nix"
    "${self}/home-manager/programs/git"
    "${self}/home-manager/programs/neovim/minimal.nix"
    "${self}/home-manager/programs/vim"
    "${self}/home-manager/programs/zsh"
  ];
in {
  inherit imports;

  home = {
    username = "jon";
    homeDirectory = "/home/jon";

    packages = with pkgs; [
      bmon # network monitor
      whois
      ltrace # lib trace
      strace # system call trace
      alejandra # format nix
      nixfmt # format nix
    ];

    stateVersion = "25.05";
  };

  programs = {};

  xdg = {
    enable = true;
    userDirs.enable = true;
    userDirs.setSessionVariables = false;
  };
}
