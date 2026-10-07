{
  pkgs,
  lib,
  ...
}: {
  services = {
    accounts-daemon.enable = true;
    acpid.enable = true; # Advanced Configuration and Power Interface
    apcupsd.enable = true; # UPS daemon

    audiobookshelf = {
      enable = true;
      host = "0.0.0.0";
      openFirewall = true;
    };

    avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
        domain = true;
        hinfo = true;
        userServices = true;
        workstation = true;
      };
    };

    blueman.enable = true; # bluetooth manager
    chrony.enable = true; # Time sync (replaces ntpd)
    clipmenu.enable = true;

    dbus.packages = [pkgs.dconf];

    devmon.enable = true;

    emacs.enable = false;

    gnome = {
      # evolution-data-server.enable = true;
      gnome-online-accounts.enable = true;
      gnome-keyring.enable = true;
    };

    flatpak = {
      enable = true;
      remotes = {
        "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        "flathub-beta" = "https://dl.flathub.org/beta-repo/flathub-beta.flatpakrepo";
      };
      packages = [
        # "flathub:app/io.github.lullabyX.sone//stable"
      ];
    };

    gvfs.enable = true; # automount
    kbfs.enable = true; # $HOME/keybase
    keybase.enable = true;

    kmscon = {
      enable = true;
      config = {
        font-name = "Fira Code";
        font-size = 12;
        font-dpi = 110;
      };
    };

    locate = {
      enable = true;
      interval = "hourly";
      package = pkgs.mlocate;
    };

    logind = {
      settings.Login = {
        HandlePowerKey = "suspend";
        HandlePowerKeyLongPress = "poweroff";
        IdleAction = "suspend";
        IdleActionSec = "60m";
        RuntimeDirectorySize = "2G";
      };
    };

    memcached.enable = true;

    ollama = {
      enable = false;
      package = pkgs.ollama-cuda;
    };

    opensearch = {
      enable = false;
      settings = {"cluster.name" = "schrödinger";};
      extraJavaOptions = ["-Xms512m" "-Xmx1g"];
    };

    pcscd.enable = true; # Smartcard reader

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };

    #     plex = {
    #       enable = true;
    #       dataDir = "/media/repository/movies";
    #       openFirewall = true;
    #       package = nixUnstable.plex;
    #     };

    protonmail-bridge.enable = true;

    pulseaudio = {
      enable = false;
      support32Bit = true;
    };

    # Mouse configuration
    ratbagd.enable = true;

    redis.servers.default = {
      enable = false;
      port = 6379;
      settings = {
        maxmemory = "512mb";
        maxmemory-policy = "allkeys-lru";
      };
    };

    # Support different DNS servers per interface
    resolved.enable = true;

    # Usenet downloader
    nzbget = {enable = true;};

    # Windows file sharing
    samba = {
      enable = true;
      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = "kepler";
          "netbios name" = "kepler";
          "security" = "user";
          "hosts allow" = ["10.9.8" "10.9.11." "localhost"];
          "hosts deny" = ["0.0.0.0/0"];
          "guest account" = "nobody";
          "map to guest" = "bad user";
        };
        public = {
          "path" = "/home/jon/public";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "yes";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "jon";
          "force group" = "users";
        };
        incoming = {
          "path" = "/home/jon/public/incoming";
          "browseable" = "no";
          "read only" = "no";
          "guest ok" = "yes";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "jon";
          "force group" = "users";
        };
      };
    };

    tumbler.enable = true; # thumbnail generator

    udev = {
      packages = [pkgs.libu2f-host pkgs.yubikey-personalization];
      extraRules = ''
        SUBSYSTEM=="block", ENV{UDISKS_FILESYSTEM_SHARED}="1"

        ACTION=="add|change", SUBSYSTEM=="block", ENV{DEVTYPE}=="disk", \
        ENV{ID_FS_UUID}=="c7639127-1de9-4afd-9978-f6f2fe1ac41f", ATTR{bdi/read_ahead_kb}="2048"

        # Generic stm32 (for flashing Preonic keyboard)
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE:="0666"

        # Teensy 2.0 / atmega32u4 (LFKpad)
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="feed", ATTRS{idProduct}=="6060", MODE:="0666"
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="0478", MODE:="0666"
      '';
    };

    # udisks2.enable = true;
    upower.enable = true;

    zerotierone = {
      enable = false;
      joinNetworks = ["8bd5124fd6f9a7e6"];
    };
  };

  systemd.oomd = {
    enable = true;
    enableRootSlice = true;
    enableUserSlices = true;
    settings.OOM = {
      SwapUsedLimit = "95%";
    };
  };

  systemd.services.NetworkManager-wait-online.enable = false;

  imports = [
    ./caddy.nix
    ./decypharr.nix
    ./hoogle
    ./immich.nix
    ./jellyfin.nix
    ./openssh.nix
    ./postgresql.nix
    ./qbittorrent.nix
    ./restic.nix
    ./xserver.nix
  ];
}
