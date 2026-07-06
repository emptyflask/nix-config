{
  inputs,
  outputs,
  lib,
  pkgs,
  ...
}: let
  common = import ../common.nix {inherit pkgs;};

  imports = [
    inputs.nixos-apple-silicon.nixosModules.default
    ./hardware-configuration.nix
  ];
in {
  inherit imports;

  boot = {
    initrd.availableKernelModules = ["xhci_pci" "usb_storage" "usbhid"];
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = false;
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  environment.shells = with pkgs; [bashInteractive zsh];

  environment.systemPackages = with pkgs;
    common.packages ++ [asahi-bless home-manager kitty rxvt-unicode wofi];

  fileSystems = {
    "/".options = ["compress=zstd"];
    "/home".options = ["compress=zstd"];
    "/nix".options = ["compress=zstd" "noatime"];
  };

  hardware.asahi = {
    peripheralFirmwareDirectory = ./firmware;
    useExperimentalGPUDriver = true;
    setupAsahiSound = true;
    withRust = true;
  };

  i18n.defaultLocale = "en_US.UTF-8";

  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [22 139 445 5000 8080];
      allowedUDPPorts = [137 138];
      allowPing = true;

      # https://discourse.nixos.org/t/docker-container-not-resolving-to-host/30259/8
      extraCommands = ''
        iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns

        iptables -I INPUT 1 -i docker0 -p tcp -d 172.17.0.1 -j ACCEPT
        iptables -I INPUT 2 -i docker0 -p udp -d 172.17.0.1 -j ACCEPT
        iptables -I INPUT 1 -s 172.16.0.0/12 -p tcp -d 172.17.0.1 -j ACCEPT
        iptables -I INPUT 2 -s 172.16.0.0/12 -p udp -d 172.17.0.1 -j ACCEPT
      '';
    };
    hostName = "newton";
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };
    wireless.iwd = {
      enable = true;
      settings.General.EnableNetworkConfiguration = true;
    };
  };

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    nixPath = ["nixpkgs=${inputs.nixpkgs-unstable}"];

    optimise.automatic = true;

    extraOptions = ''
      keep-derivations = true
      keep-outputs = true
      min-free = ${toString (100 * 1024 * 1024)} # 100MiB
      max-free = ${toString (1024 * 1024 * 1024)} # 1GiB
    '';

    settings = {
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["root" "jon"];
      extra-substituters = ["https://nix-community.cachix.org"];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  # nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [outputs.overlays.additions outputs.overlays.modifications];

  programs = {
    # _1password.enable = true;
    # _1password-gui = {
    #   enable = true;
    #   polkitPolicyOwners = [ "jon" ];
    # };
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    hyprland.enable = true;
    # seahorse.enable = true;
    ssh.startAgent = false;
    # steam.enable = true;
    sway.enable = true;
    zsh.enable = true;
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
    tzupdate.enable = true;
  };

  system.stateVersion = "25.05";

  users.mutableUsers = true;

  users.users.jon = {
    initialPassword = "changeme";
    isNormalUser = true;
    extraGroups = ["wheel"];
    shell = pkgs.zsh;
  };

  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };
}
