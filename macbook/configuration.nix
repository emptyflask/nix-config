{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    inputs.nixos-apple-silicon.nixosModules.default
    ./hardware-configuration.nix
  ];

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "usb_storage"
      "usbhid"
    ];

    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = false;
  };

  hardware.asahi = {
    peripheralFirmwareDirectory = ./firmware;
    useExperimentalGPUDriver = true;
    setupAsahiSound = true;
    withRust = true;
  };

  fileSystems = {
    "/".options = [ "compress=zstd" ];
    "/home".options = [ "compress=zstd" ];
    "/nix".options = [
      "compress=zstd"
      "noatime"
    ];
  };

  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = ["root" "jon"];
    };
  };

  networking = {
    networkmanager.enable = true;
    networkmanager.wifi.backend = "iwd";
    wireless.iwd = {
      enable = true;
      settings.General.EnableNetworkConfiguration = true;
    };
  };

  environment.shells = with pkgs; [bashInteractive zsh];

  environment.systemPackages = with pkgs; [
    asahi-bless
    git
    kitty
    rxvt-unicode
    vim
    wofi
  ];

  programs = {
    hyprland.enable = true;
    sway.enable = true;
    zsh.enable = true;
  };

  users.mutableUsers = true;

  users.users.jon = {
    initialPassword = "changeme";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
   };

  services = {
    kanata = {
      enable = true;
      keyboards = {
        "default".config = ''
          (defsrc caps)
          (deflayer default @ctrl-esc)
          (defalias
            ctrl-esc (tap-hold-release 100 100 esc lctl)
          )
        '';
      };
    };
  };

  system.stateVersion = "25.05";
}
