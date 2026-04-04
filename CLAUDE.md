# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Nix flake-based system configuration managing multiple machines:
- **kepler** — primary x86_64-linux desktop (NixOS + home-manager)
- **gaudi** — aarch64-darwin Mac (nix-darwin + home-manager)
- **newton** — aarch64-linux Apple Silicon (NixOS via nixos-apple-silicon + home-manager)
- **planck** — aarch64-linux Raspberry Pi 4 (NixOS via nixos-raspberrypi)

## Common Commands

```bash
# Format all nix files
nix fmt

# Build/check a config without activating
nix build .#nixosConfigurations.kepler.config.system.build.toplevel

# Apply NixOS config (on the target machine, using `nh`)
nh os switch /home/jon/dev/nix-config -- --flake .#kepler

# Apply home-manager config (on the target machine)
nh home switch /home/jon/dev/nix-config -- --flake .#jon@kepler

# Check flake for errors
nix flake check

# Update all flake inputs
nix flake update

# Update a single input
nix flake update nixpkgs
```

## Architecture

### Directory Structure

- `flake.nix` — inputs declaration; outputs delegate to `outputs.nix`
- `outputs.nix` — defines `nixosConfigurations`, `darwinConfigurations`, `homeConfigurations`, `packages`, `overlays`, `nixosModules`, `homeManagerModules`
- `hosts/<name>/` — per-host NixOS/darwin system config and `home.nix` (home-manager entry point)
- `hosts/common.nix` — shared NixOS settings applied to all hosts: nix settings, GC, store optimisation, nixpkgs overlays, base packages
- `nixos/` — reusable NixOS modules (`security/`, `users/`, `modules/`)
- `home-manager/` — shared home-manager config, split into:
  - `common.nix` — universal programs (direnv, fzf, zoxide, bat, ripgrep, etc.)
  - `environment.nix` — session variables
  - `accounts/` — email/calendar account definitions
  - `programs/<app>/` — per-app config (neovim, zsh, tmux, git, kitty, alacritty, yazi, etc.)
  - `services/<svc>/` — user services (dunst, mpd, spotifyd, trayer, gpg-agent, polybar)
  - `xmonad/`, `xmobar/`, `xresources/` — X11 window manager config
  - `locations/` — geographic coordinates for redshift and similar
- `modules/nixos/` — exportable NixOS modules (`arrs.nix`, `printing.nix`, `local-ca.nix`)
- `modules/home-manager/` — exportable home-manager modules
- `overlays/` — nixpkgs overlays; `additions` pulls from `pkgs/`, `modifications` patches existing packages (postman, karabiner-elements, yazi)
- `pkgs/` — custom package definitions
- `inputs/neovim-plugins/` — sub-flake pinning neovim plugin sources as `flake = false` inputs

### Key Conventions

- **nixpkgs channels**: stable (`nixos-25.11`) for kepler/planck; `nixos-unstable` for gaudi/newton. `home-manager` follows the same split.
- **Nix implementation**: All hosts use `lixPackageSets.stable.lix` (Lix fork) instead of upstream Nix.
- **Secrets**: `agenix` is available as an input and its NixOS module is loaded on kepler; secrets files live outside this repo.
- **Formatter**: `alejandra` (run via `nix fmt`).
- **home-manager integration**: On NixOS hosts it runs as a NixOS module (`home-manager.nixosModules.home-manager`); standalone configurations also exist for each user@host in `homeConfigurations`.
- **Overlays are applied globally** via `hosts/common.nix` for NixOS hosts; darwin and standalone HM configs apply them separately.
- `self` (the flake itself) is passed as `extraSpecialArgs` so home-manager modules can reference repo files with `"${self}/home-manager/..."`.
