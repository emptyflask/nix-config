# newton NixOS Configuration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the stale Apple Silicon newton config with a full x86_64 server configuration running Immich, Pi-hole, Home Assistant, and Traefik natively via NixOS modules.

**Architecture:** All services use native NixOS modules (no containers). Traefik handles HTTP routing for `.newton.lan` hostnames. Home-manager is integrated as a NixOS module (matching kepler's pattern) for a minimal server console environment.

**Tech Stack:** NixOS (nixpkgs-unstable), home-manager-unstable, services.immich, services.pihole-ftl, services.pihole-web, services.home-assistant, services.traefik, zsh, neovim (minimal), tmux

---

## File Map

| Action | Path | Responsibility |
|--------|------|----------------|
| Modify | `outputs.nix` | newton entry: x86_64-linux, add home-manager module, remove standalone homeConfiguration |
| Replace | `hosts/newton/hardware-configuration.nix` | x86_64 placeholder (must be regenerated on machine) |
| Replace | `hosts/newton/default.nix` | System config: boot, networking, firewall, programs |
| Replace | `hosts/newton/home.nix` | Minimal server home-manager config |
| Create | `hosts/newton/services/default.nix` | openssh, immich, pihole-ftl, pihole-web, home-assistant |
| Create | `hosts/newton/services/traefik.nix` | Traefik HTTP routing for .newton.lan |

---

## Task 1: Update outputs.nix

**Files:**
- Modify: `outputs.nix`

Newton needs to switch from `aarch64-linux` to `x86_64-linux`, gain home-manager as a NixOS module, and lose the stale standalone `homeConfigurations."jon@newton"` entry.

- [ ] **Step 1: Replace the newton nixosConfigurations entry**

In `outputs.nix`, find and replace the entire `newton = ...` block inside `nixosConfigurations`:

```nix
    newton = inputs.nixpkgs-unstable.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs outputs;};
      pkgs = inputs.nixpkgs-unstable.legacyPackages.x86_64-linux;
      modules = [
        ./hosts/newton
        inputs.home-manager-unstable.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.jon = ./hosts/newton/home.nix;
            extraSpecialArgs = {inherit inputs outputs;};
          };
        }
      ];
    };
```

- [ ] **Step 2: Remove the standalone homeConfigurations entry for newton**

Delete the entire `"jon@newton" = ...` block from `homeConfigurations`. It is superseded by the NixOS module approach above.

- [ ] **Step 3: Verify the flake evaluates**

```bash
cd /home/jon/dev/nix-config
nix flake show 2>&1 | grep -A2 newton
```

Expected output includes `newton` under `nixosConfigurations` with no errors.

- [ ] **Step 4: Commit**

```bash
git add outputs.nix
git commit -m "feat(newton): switch to x86_64, integrate home-manager as NixOS module"
```

---

## Task 2: Replace hardware-configuration.nix

**Files:**
- Replace: `hosts/newton/hardware-configuration.nix`

The existing file was generated on an Apple Silicon MacBook. This creates a correct x86_64 placeholder. The actual file must be regenerated on the physical 2012 MacBook Pro after NixOS install using `nixos-generate-config`.

- [ ] **Step 1: Overwrite hardware-configuration.nix with an x86_64 placeholder**

```nix
# This is a PLACEHOLDER. Regenerate on the actual machine:
#   nixos-generate-config --show-hardware-config > hosts/newton/hardware-configuration.nix
# Then commit the real file.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [];

  # TODO: replace UUIDs with actual values from `blkid` on the machine
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/REPLACE-ROOT-UUID";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/REPLACE-BOOT-UUID";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  swapDevices = [];

  networking.useDHCP = lib.mkDefault false;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
```

- [ ] **Step 2: Commit**

```bash
git add hosts/newton/hardware-configuration.nix
git commit -m "feat(newton): replace Apple Silicon hardware-configuration with x86_64 placeholder"
```

---

## Task 3: Rewrite hosts/newton/default.nix

**Files:**
- Replace: `hosts/newton/default.nix`

Replaces the Apple Silicon/Asahi/Hyprland config with a headless server config: static IP on ethernet, firewall for the services, no GUI programs.

Note: The ethernet interface name (`enp1s0` below) must be confirmed on the machine with `ip link`. Common names on 2012 MBP are `enp1s0` or `eth0`.

- [ ] **Step 1: Overwrite hosts/newton/default.nix**

```nix
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

  nixpkgs = {
    overlays = [ outputs.overlays.additions outputs.overlays.modifications ];
    config.allowUnfree = true;
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
```

- [ ] **Step 2: Verify the config evaluates**

```bash
nix build .#nixosConfigurations.newton.config.system.build.toplevel --dry-run 2>&1 | tail -5
```

Expected: either `these derivations will be built` or `these paths will be fetched` — no evaluation errors.

- [ ] **Step 3: Commit**

```bash
git add hosts/newton/default.nix
git commit -m "feat(newton): rewrite as x86_64 headless server config"
```

---

## Task 4: Create hosts/newton/services/default.nix

**Files:**
- Create: `hosts/newton/services/default.nix`

All four services plus SSH. Pi-hole's web interface listens on port 8080 (avoiding conflict with Traefik on 80). Immich data is at `/media/immich` — this directory is created via tmpfiles and will move to the second SSD when installed.

- [ ] **Step 1: Create hosts/newton/services/default.nix**

```nix
{ config, pkgs, lib, ... }:

{
  imports = [ ./traefik.nix ];

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        X11Forwarding = false;
      };
    };

    immich = {
      enable = true;
      mediaLocation = "/media/immich";
      openFirewall = false; # handled in networking.firewall in default.nix
    };

    pihole-ftl = {
      enable = true;
      settings.dns.upstreams = [ "9.9.9.9" "1.1.1.1" ];
    };

    pihole-web = {
      enable = true;
      # Listen on 8080 so Traefik can own port 80
      settings.webserver.port = "8080";
    };

    home-assistant = {
      enable = true;
      openFirewall = false; # handled in networking.firewall in default.nix
      config = {
        homeassistant = {
          name = "Home";
          unit_system = "metric";
          time_zone = config.time.timeZone;
        };
        http = {};
        default_config = {};
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /media 0755 root root -"
    "d /media/immich 0755 immich immich -"
  ];
}
```

- [ ] **Step 2: Verify the config evaluates**

```bash
nix build .#nixosConfigurations.newton.config.system.build.toplevel --dry-run 2>&1 | tail -5
```

Expected: no evaluation errors.

- [ ] **Step 3: Commit**

```bash
git add hosts/newton/services/default.nix
git commit -m "feat(newton): add services: openssh, immich, pihole, home-assistant"
```

---

## Task 5: Create hosts/newton/services/traefik.nix

**Files:**
- Create: `hosts/newton/services/traefik.nix`

HTTP-only Traefik using the same `proxy` helper pattern as kepler. Routes three `.newton.lan` hostnames. No TLS entrypoint configured.

- [ ] **Step 1: Create hosts/newton/services/traefik.nix**

```nix
{ config, lib, ... }:

{
  services.traefik = {
    enable = true;

    staticConfigOptions = {
      api = {
        dashboard = false;
        insecure = false;
      };
      entryPoints.web = { address = ":80"; };
    };

    dynamicConfigOptions = {
      http = let
        proxy = host: port: {
          routers."${host}" = {
            rule = "Host(`${host}`)";
            entryPoints = [ "web" ];
            service = host;
          };
          services."${host}".loadBalancer.servers = [
            { url = "http://localhost:${toString port}/"; }
          ];
        };
      in
        lib.mkMerge [
          (proxy "immich.newton.lan"        2283)
          (proxy "pihole.newton.lan"        8080)
          (proxy "homeassistant.newton.lan" 8123)
        ];
    };
  };
}
```

- [ ] **Step 2: Verify the config evaluates**

```bash
nix build .#nixosConfigurations.newton.config.system.build.toplevel --dry-run 2>&1 | tail -5
```

Expected: no evaluation errors.

- [ ] **Step 3: Commit**

```bash
git add hosts/newton/services/traefik.nix
git commit -m "feat(newton): add traefik routing for .newton.lan services"
```

---

## Task 6: Rewrite hosts/newton/home.nix

**Files:**
- Replace: `hosts/newton/home.nix`

Minimal server console home — shared modules for git, zsh, tmux, neovim (minimal), starship. No GUI modules, no workstation packages, no fonts, no browsers.

- [ ] **Step 1: Overwrite hosts/newton/home.nix**

```nix
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
```

- [ ] **Step 2: Verify the full build evaluates**

```bash
nix build .#nixosConfigurations.newton.config.system.build.toplevel --dry-run 2>&1 | tail -10
```

Expected: no evaluation errors, a list of derivations/paths to build.

- [ ] **Step 3: Commit**

```bash
git add hosts/newton/home.nix
git commit -m "feat(newton): minimal server home-manager config"
```

---

## Post-Install Notes

These steps are done on the physical machine after deploying, not part of this config:

1. **Confirm ethernet interface name:** `ip link` — update `networking.interfaces.<name>` in `default.nix` if not `enp1s0`
2. **Regenerate hardware-configuration.nix:** `nixos-generate-config --show-hardware-config` — commit the real output
3. **Point your router's DHCP/DNS** at `10.9.8.10` for network-wide Pi-hole
4. **Add DNS entries** in your router or Pi-hole for `*.newton.lan → 10.9.8.10`
5. **Second SSD:** When the optibay drive is installed, mount it at `/media` and Immich will use it automatically (the tmpfiles rule creates the directory there)
