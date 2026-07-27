{ inputs, pkgs, nix, nixpkgs, config, lib, ... }:
{
  imports = [
    # ./skhd.nix
    # ./sketchybar.nix
    ./system-defaults.nix
    # ./yabai.nix
  ];

  # config.stylix.autoEnable = true;

  # Match the Lix pin used on every other host (hosts/common.nix) instead of
  # nix-darwin's default of plain upstream Nix.
  nix.package = pkgs.lixPackageSets.stable.lix;

  environment.systemPackages = with pkgs;
    [
      alacritty
      cabal-install
      coreutils
      ffmpeg
      fswatch
      fzf
      gnupg
      home-manager
      karabiner-elements
      neovim
      nmap
      nodejs
      openssl
      p7zip
      reattach-to-user-namespace
      ripgrep
      sqlite
      tree
      vim
      w3m
      wget
      yarn
      zip
    ];

  fonts = {
    packages = with pkgs; [
      aileron
      cascadia-code
      fira-code
      iosevka
    ];
  };

  homebrew = {
    enable = true;
    brews = [];
    casks = [
      "alfred"
      "dash"
      "iterm2"
      # "karabiner-elements"
      "protonvpn"
    ];
  };

  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  nix.gc = {
    automatic = true;
    # interval = "weekly";
    options = "--delete-older-than 30d";
  };

  nix.optimise.automatic = true;

  nix.extraOptions = ''
    keep-derivations = true
    keep-outputs = true
    min-free = ${toString (100 * 1024 * 1024)} # 100MiB
    max-free = ${toString (1024 * 1024 * 1024)} # 1GiB
  '';
  nix.settings = {
    experimental-features = "nix-command flakes";
    sandbox = true;

    substituters = [
      "https://nix-community.cachix.org"
      # "https://cache.iog.io"
      "https://cache.nixos.org/"
      # "https://devenv.cachix.org"
      # "https://digitallyinduced.cachix.org"
      "https://ghcide-nix.cachix.org"
    ];

    trusted-public-keys = [
      "cache.iog.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "digitallyinduced.cachix.org-1:y+wQvrnxQ+PdEsCt91rmvv39qRCYzEgGQaldK26hCKE="
      "ghcide-nix.cachix.org-1:ibAY5FD+XWLzbLr8fxK6n8fL9zZe7jS+gYeyxyWYK5c="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    trusted-users = [ "root" "jonroberts" ];
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.zsh.enable = true;

  services.karabiner-elements.enable = false;

  system.stateVersion = 4;

  system.primaryUser = "jonroberts";

  users = {
    users.jonroberts = {
      home = /Users/jonroberts;
    };
  };

}
