{ inputs, outputs, pkgs, ... }:

{
  imports = [
    ../../home-manager/common.nix
    ../../home-manager/environment.nix
    ../../home-manager/programs/git
    ../../home-manager/programs/neovim/minimal.nix
    ../../home-manager/programs/starship
    ../../home-manager/programs/tmux
    ../../home-manager/programs/vim
    ../../home-manager/programs/zsh
  ];

  home = {
    username = "jon";
    homeDirectory = "/home/jon";

    packages = with pkgs; [
      cachix
      docker-compose
      glow        # markdown viewer
      hexyl       # hex viewer
      lazydocker  # docker/container TUI
      whois
    ];

    stateVersion = "25.11";
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 60 * 60 * 4;
    enableSshSupport = true;
  };
}
