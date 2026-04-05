{ pkgs, ... }:
{
  home = {
    username = "jon";
    homeDirectory = "/home/jon";

    packages = with pkgs; [
      bmon # network monitor
      whois
      ltrace # lib trace
      strace # system call trace
      alejandra # format nix
      nixfmt-classic # format nix
    ];

    stateVersion = "25.05";
  };

  programs = {};

  xdg = {
    enable = true;
    userDirs.enable = true;
  };
}
