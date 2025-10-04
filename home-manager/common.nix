{ outputs, pkgs, ... }:

{
  # nixpkgs = {
  #   overlays = [ outputs.overlays.additions outputs.overlays.modifications ];
  #   config = {
  #     allowUnfree = true;
  #     # Workaround for https://github.com/nix-community/home-manager/issues/2942
  #     allowUnfreePredicate = _: true;
  #   };
  # };

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    fzf.enable = true;
    home-manager.enable = true;
    zoxide.enable = true;
  };

  home.packages = with pkgs; [
    bat # cat clone with syntax highlighting and git integration
    bc # cli calculator
    du-dust # rust modern clone of du
    fd # find entries in filesystem
    htop
    jq
    killall
    magic-wormhole # simple secure file transfer
    nix-index
    nix-prefetch-git
    parallel # run commands in parallel
    ripgrep
    ripgrep-all
    shared-mime-info # recognize file types
    tealdeer # tldr for various shell tools
    units
  ];

}
