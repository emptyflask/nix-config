{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    ./hardware-configuration.nix
    ../../nixos/security
    ../../nixos/users
    ../common.nix
    ./filesystems.nix
    # ./nfs.nix
    ./services
    (import ./scanner.nix {
      inherit pkgs;
      user = "jon";
    })

    outputs.nixosModules.arrs
    outputs.nixosModules.printing
  ];

  nix.settings = {
    extra-platforms = ["i686-linux"];
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  boot = {
    kernel = {
      sysctl = {
        "kernel.sysrq" = 1;
        "vm.swappiness" = 20;
      };
    };
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

    binfmt.emulatedSystems = ["aarch64-linux"];

    # Kernel modules:
    # don't load module for secondary ethernet adapter
    blacklistedKernelModules = ["alx"];
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
      wifi.backend = "iwd";
    };

    firewall = let
    in {
      enable = true;
      allowedTCPPorts = let
        homeAssistant = 8123;
        jellyfinPorts = [8096 8920];
        plexPorts = [32400 3005 8324 32469];
        sambaPorts = [139 445];
        ssh = 22;
      in
        [homeAssistant ssh] ++ jellyfinPorts ++ sambaPorts ++ plexPorts;
      allowedUDPPorts = let
        jellyfinPorts = [7359];
        netbiosPorts = [137 138];
        plexPorts = [1900 5353 32410 32412 32413 32414];
      in
        jellyfinPorts ++ netbiosPorts ++ plexPorts;
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
      settings = {Settings = {AutoConnect = true;};};
    };
  };

  environment.systemPackages = with pkgs; [
    feh
    firefox
    rxvt-unicode
    (steam.override {extraPkgs = pkgs: [wavpack];}).run
    vim-full
    xclip
    xkill
    xmessage
    xsel
  ];

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      aileron
      corefonts
      dejavu_fonts
      fira
      fira-code
      fira-code-symbols
      fira-mono
      helvetica-neue-lt-std
      ibm-plex
      inconsolata
      inter
      liberation_ttf
      libre-baskerville
      libre-bodoni
      libre-caslon
      libre-franklin
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      roboto
      ubuntu-classic
      vista-fonts
    ];
    fontconfig = {
      defaultFonts = {
        serif = ["DejaVu Serif"];
        sansSerif = ["DejaVu Sans"];
        monospace = ["Fira Mono"];
      };
    };
  };

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = ["jon"];
  };
  programs.command-not-found.enable = false;
  programs.dconf.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.nh = {
    enable = true;
    flake = "/home/jon/dev/nix-config";
  };
  programs.nix-ld.enable = true; # For running non-nix binaries
  programs.seahorse.enable = true;
  programs.ssh.startAgent = false;
  programs.steam.enable = true;
  programs.zsh = {
    enable = true;
    enableLsColors = true;
  };

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

    # Use GPU inside Docker and Podman containers
    nvidia-container-toolkit.enable = true;

    graphics.enable = true;
    graphics.enable32Bit = true;
    # graphics.extraPackages32 = with pkgs.pkgsi686Linux; [libva];

    sane.enable = true; # enable scanner support

    # video.hidpi.enable = false;
  };

  virtualisation = {
    docker = {
      enable = true;
      autoPrune.enable = true;
      # For GPU support in docker containers
      daemon.settings.features.cdi = true;
    };
    podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    libvirtd.enable = true;

    oci-containers.containers = {
      homeassistant = {
        volumes = ["home-assistant:/config"];
        environment.TZ = config.time.timeZone;
        image = "ghcr.io/home-assistant/home-assistant:stable";
        extraOptions = [
          "--network=host"
          # "--device=/dev/ttyACM0:/dev/ttyACM0"
        ];
      };

      # plex = {
      #   environment = {
      #     TZ = config.time.timeZone;
      #     PUID = toString config.users.users.plex.uid;
      #     PGID = toString config.users.groups.media.gid;
      #     PLEX_CLAIM = "claim-yxovhjy9R4QmnHSVMvUZ";
      #     VERSION = "latest";
      #   };
      #   extraOptions = [ "--network=host" ];
      #   image = "linuxserver/plex";
      #   volumes =
      #     [ "/media/repository/movies:/media" "/media/plex-config:/config" ];
      # };
    };
  };

  xdg.portal = {
    enable = true;
    config.common.default = "gtk";
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
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
