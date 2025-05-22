{ inputs, outputs, lib, config, pkgs, ... }:

let
  common = import ../common.nix { inherit pkgs; };

  plexTcpPorts = [ 32400 3005 8324 32469 ];
  plexUdpPorts = [ 1900 5353 32410 32412 32413 32414 ];

in {
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    ./hardware-configuration.nix
    ../../nixos/security
    ../../nixos/services
    ../../nixos/users
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = { allowUnfree = true; };
  };

  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix.registry = (lib.mapAttrs (_: flake: { inherit flake; }))
    ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  environment.etc = lib.mapAttrs' (name: value: {
    name = "nix/path/${name}";
    value.source = value.flake;
  }) config.nix.registry;

  nix.gc = {
    automatic = true;
    dates = "weekly";
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
    auto-optimise-store = true;
    experimental-features = "nix-command flakes";
    sandbox = true;

    substituters = [
      "https://nix-community.cachix.org"
      # "https://cache.iog.io"
      # "https://devenv.cachix.org"
      # "https://digitallyinduced.cachix.org"
      # "https://ghcide-nix.cachix.org"
    ];

    trusted-public-keys = [
      # "cache.iog.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      # "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      # "digitallyinduced.cachix.org-1:y+wQvrnxQ+PdEsCt91rmvv39qRCYzEgGQaldK26hCKE="
      # "ghcide-nix.cachix.org-1:ibAY5FD+XWLzbLr8fxK6n8fL9zZe7jS+gYeyxyWYK5c="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  fileSystems."/media/repository" = {
    device = "/dev/disk/by-uuid/8CFA8C6CFA8C547C";
    fsType = "ntfs";
    options = [ "defaults" "user" ];
  };

  # fileSystems."/media/backup" =
  #   { device = "/dev/disk/by-uuid/82d748cc-d038-405c-9d5d-82d381a0999e";
  #   fsType = "ext4";
  #   options = ["defaults" "nofail" "user"];
  # };

  boot = {
    kernel = { sysctl = { "vm.swappiness" = "20"; }; };
    loader = {
      efi.canTouchEfiVariables = true;
      # grub = {
      #   enable = true;
      #   device = "nodev";
      #   efiSupport = true;
      #   useOSProber = true;
      #   version = 2;
      # };
      systemd-boot = {
        enable = true;
        configurationLimit = 32;
        consoleMode = "max";
        memtest86.enable = true;
      };
    };

    # Kernel modules:
    # don't load module for secondary ethernet adapter
    blacklistedKernelModules = [ "alx" ];
    # disable usb suspend so devices work after waking
    extraModprobeConfig = ''
      options usbcore       autosuspend=-1
    '';
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  i18n.defaultLocale = "en_US.UTF-8";

  time.timeZone = "America/Chicago";

  networking = {
    hostName = "kepler";

    networkmanager = {
      enable = true;
      enableStrongSwan = true;
      wifi.backend = "iwd";
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 139 445 5000 8080 ] ++ plexTcpPorts;
      allowedUDPPorts = [ 137 138 ] ++ plexUdpPorts;
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

    wireless.iwd = {
      enable = true;
      settings = { Settings = { AutoConnect = true; }; };
    };
  };

  environment.systemPackages = with pkgs;
    common.packages ++ [
      feh
      firefox
      rxvt-unicode
      (steam.override { extraPkgs = pkgs: [ wavpack ]; }).run
      xclip
      xorg.xkill
      xorg.xmessage
      xsel
      vimHugeX
    ];

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs;
      common.fonts ++ [
        aileron
        helvetica-neue-lt-std
        ibm-plex
        inconsolata
        inter
        liberation_ttf
        libre-baskerville
        libre-bodoni
        libre-caslon
        libre-franklin
      ];
    fontconfig = {
      defaultFonts = {
        serif = [ "DejaVu Serif" ];
        sansSerif = [ "DejaVu Sans" ];
        monospace = [ "Fira Mono" ];
      };
    };
  };

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "jon" ];
  };
  programs.adb.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep 5 --keep-since 30d";
    flake = "/home/jon/dev/nix-config";
  };
  programs.seahorse.enable = true;
  programs.ssh.startAgent = false;
  programs.steam.enable = true;
  programs.zsh.enable = true;

  hardware = {
    alsa.enablePersistence = true;
    bluetooth.enable = true;

    nvidia = {
      # Modesetting is required.
      modesetting.enable = true;

      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      # Enable this if you have graphical corruption issues or application crashes after waking
      # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
      # of just the bare essentials.
      powerManagement.enable = true;

      # Fine-grained power management. Turns off GPU when not in use.
      # Experimental and only works on modern Nvidia GPUs (Turing or newer).
      powerManagement.finegrained = false;

      # Use the NVidia open source kernel module (not to be confused with the
      # independent third-party "nouveau" open source driver).
      # Support is limited to the Turing and later architectures. Full list of
      # supported GPUs is at:
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
      # Only available from driver 515.43.04+
      open = true;

      # Enable the Nvidia settings menu,
      # accessible via `nvidia-settings`.
      nvidiaSettings = true;

      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      # package = config.boot.kernelPackages.nvidiaPackages.production;
    };

    pulseaudio.enable = true;
    pulseaudio.support32Bit = true;

    graphics.enable = true;
    graphics.enable32Bit = true;
    graphics.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];

    # video.hidpi.enable = false;
  };

  virtualisation = {
    docker = {
      enable = true;
      autoPrune.enable = true;
    };
    podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    libvirtd.enable = true;
    virtualbox = {
      host.enable = true;
      # enable extension pack to share usb ports, etc.
      # (requires building virtualbox)
      # host.enableExtensionPack = true;
      host.addNetworkInterface = true;
    };
    # oci-containers.containers.plex = {
    #   environment = {
    #     TZ = "America/Chicago";
    #     PUID = toString config.users.users.plex.uid;
    #     PGID = toString config.users.groups.media.gid;
    #     PLEX_CLAIM = "claim-yxovhjy9R4QmnHSVMvUZ";
    #     VERSION = "latest";
    #   };
    #   extraOptions = ["--network=host"];
    #   image = "linuxserver/plex";
    #   volumes = [
    #     "/media/repository/movies:/media"
    #     "/media/plex-config:/config"
    #   ];
    # };
  };

  xdg.portal = {
    enable = true;
    config.common.default = "lxqt";
    lxqt = {
      enable = true;
      styles = [ ];
    };
  };

  zramSwap = {
    enable = true;
    memoryPercent = 25;
    priority = 100;
  };

  system = {
    autoUpgrade.enable = false;

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "22.05";
  };

}
