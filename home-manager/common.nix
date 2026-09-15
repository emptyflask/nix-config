{
  outputs,
  pkgs,
  ...
}: {
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
    dust # rust modern clone of du
    fd # find entries in filesystem
    htop
    jq
    killall
    magic-wormhole # simple secure file transfer
    nix-prefetch-git
    parallel # run commands in parallel
    restic
    restic-b2 # wraps restic with b2 backup credentials decrypted via agenix
    ripgrep
    ripgrep-all
    shared-mime-info # recognize file types
    tealdeer # tldr for various shell tools
    units
  ];
}
