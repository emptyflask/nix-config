{ inputs, outputs, lib, config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../nixos/users
    ../common.nix
    ./services
  ];

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        configurationLimit = 32;
        consoleMode = "max";
      };
    };
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/Chicago";

  networking = {
    hostName = "newton";
    useDHCP = false;

    # TODO: confirm interface name on machine with `ip link`
    interfaces.enp1s0.ipv4.addresses = [{
      address = "10.9.8.10";
      prefixLength = 24;
    }];
    defaultGateway = "10.9.8.1";

    # Point at ourselves first (Pi-hole), fallback to Cloudflare
    nameservers = [ "127.0.0.1" "1.1.1.1" ];

    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [ 22 53 80 2283 8123 ];
      allowedUDPPorts = [ 53 ];
    };
  };

  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    nh = {
      enable = true;
      flake = "/home/jon/dev/nix-config";
    };
    ssh.startAgent = false;
    zsh.enable = true;
  };

  system.stateVersion = "25.11";
}
