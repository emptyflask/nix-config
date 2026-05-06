# newton NixOS Configuration Design

**Date:** 2026-05-06
**Machine:** 2012 MacBook Pro

## Overview

Add a NixOS server configuration for `newton`, a 2012 MacBook Pro repurposed as a home server. It replaces a previous experimental newton config (Apple Silicon MacBook, now abandoned). The machine runs four services — Immich, Pi-hole, Home Assistant, and Traefik — all via native NixOS modules.

## System

- **Platform:** `x86_64-linux`
- **nixpkgs channel:** `nixpkgs-unstable` (already in use; needed for `services.immich` and `services.pihole-ftl`)
- **Boot:** systemd-boot, EFI
- **Networking:** Ethernet only, static IP `10.9.8.10`, no WiFi/iwd
- **Storage:** Main 512GB SSD. A second SSD (optibay) is planned. Immich data lives at `/media/immich` — this path will move to the second drive when installed.
- **TLS:** None for now. All services HTTP only.
- **Domain suffix:** `.newton.lan`

### outputs.nix changes

- Change newton `nixosConfigurations` entry: `aarch64-linux` → `x86_64-linux`, `nixpkgs-unstable` stays
- Add home-manager as a NixOS module inside `nixosConfigurations.newton` (matching kepler's pattern)
- Remove the standalone `homeConfigurations."jon@newton"` entry (superseded by the NixOS module approach)

### hardware-configuration.nix

The existing file is stale (generated on Apple Silicon). It must be regenerated on the physical 2012 MacBook Pro using `nixos-generate-config`. A placeholder x86_64 file will be committed; the real one replaces it at install time.

## Services

Services are split into `hosts/newton/services/default.nix` and `hosts/newton/services/traefik.nix`, mirroring kepler's structure.

### Traefik

`services.traefik`, HTTP only (port 80). A `proxy` helper function (same pattern as kepler) maps hostnames to local ports:

| Hostname                   | Port |
|----------------------------|------|
| `immich.newton.lan`        | 2283 |
| `pihole.newton.lan`        | pihole-web port |
| `homeassistant.newton.lan` | 8123 |

No TLS entrypoint configured. No ACME.

### Immich

`services.immich` (native NixOS module). Data directory: `/media/immich`. Opens firewall on port 2283.

### Pi-hole

`services.pihole-ftl` for DNS, `services.pihole-web` for the dashboard. DNS listens on port 53 (TCP+UDP). Upstream DNS: Quad9 (`9.9.9.9`) and Cloudflare (`1.1.1.1`).

### Home Assistant

`services.home-assistant`. Listens on port 8123.

### SSH

`services.openssh`, key-auth only, no password authentication, no root login.

### Firewall

| Port | Protocol | Purpose         |
|------|----------|-----------------|
| 22   | TCP      | SSH             |
| 53   | TCP+UDP  | Pi-hole DNS     |
| 80   | TCP      | Traefik HTTP    |

## Home Environment

Managed via home-manager as a NixOS module. Server-only — no GUI, no desktop tooling.

### Shared modules included

- `home-manager/common.nix` (bat, fd, ripgrep, fzf, zoxide, direnv, etc.)
- `home-manager/environment.nix`
- `home-manager/programs/git`
- `home-manager/programs/zsh`
- `home-manager/programs/tmux`
- `home-manager/programs/neovim/minimal.nix` (not the full workstation config)
- `home-manager/programs/vim`
- `home-manager/programs/starship`

### Shared modules excluded

xmonad, xmobar, xresources, alacritty, kitty, rofi, dunst, spotifyd, trayer, neomutt, zathura, yazi

### Home packages

Minimal set of server-useful tools:

- `lazydocker`, `docker-compose` (container inspection)
- `glow` (markdown viewer)
- `whois`, `hexyl` (network/hex utilities)
- `cachix`

All fonts, media players, browsers, chat apps, and language toolchains are excluded.

## File Structure

```
hosts/newton/
  default.nix               # system config (replaces Apple Silicon version)
  home.nix                  # minimal server home-manager config
  hardware-configuration.nix  # placeholder; regenerate on machine
  services/
    default.nix             # all services except traefik
    traefik.nix             # traefik routing config
outputs.nix                 # updated newton entry
```
