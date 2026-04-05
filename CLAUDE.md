# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Nix flake-based system configuration managing multiple machines using the **den** framework (github:vic/den) with **flake-parts** and **import-tree**:
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

### Framework: den + flake-parts + import-tree

`flake.nix` outputs are built via `flake-parts` with every `.nix` file under `modules/` auto-imported by `import-tree`. Each file is a flake-parts module. `den` provides the host/user/aspect system.

- `den.hosts.<system>.<name>` — declare a host and its users
- `den.homes.<system>.<user@host>` — declare standalone home-manager configs
- `den.aspects.<name>` — aspect (feature) definitions containing `.nixos`, `.darwin`, `.homeManager` configs
- `den.aspects.<name>.provides.<target>` — config provided when aspect lives alongside `target`
- `den.aspects.<name>.includes` — aspect dependencies

### Directory Structure

- `flake.nix` — inputs; outputs delegate to flake-parts + import-tree
- `modules/` — all flake-parts modules (auto-imported):
  - `den.nix` — imports `inputs.den.flakeModule`
  - `defaults.nix` — `den.schema` and `den.default.includes`
  - `systems.nix`, `formatter.nix`, `packages.nix`, `overlays.nix`, `exported-modules.nix`
  - `hosts/<name>.nix` — `den.hosts` + `den.aspects.<name>` (OS-level config)
  - `hosts/_<name>-home.nix` — host-specific home-manager settings (ignored by import-tree)
  - `users/jon.nix` — `den.aspects.jon` with `provides.<host>` for per-host HM config
  - `features/*.nix` — `den.aspects.<feature>` definitions (git, shell, editor, desktop, music, mail, etc.)
- `hosts/<name>/` — per-host NixOS/darwin system config (hardware, services, filesystems)
- `hosts/common.nix` — shared NixOS settings (nix, GC, store optimisation, base packages)
- `nixos/` — reusable NixOS modules (`security/`, `users/`)
- `lib/nixos/` — exportable NixOS modules (arrs, printing, local-ca)
- `lib/home-manager/` — exportable home-manager modules
- `home-manager/` — shared home-manager config:
  - `common.nix`, `environment.nix` — base programs and session vars
  - `accounts/` — email/calendar account definitions
  - `programs/<app>/` — per-app config (neovim, zsh, tmux, git, kitty, alacritty, yazi, etc.)
  - `services/<svc>/` — user services (dunst, mpd, spotifyd, trayer)
  - `xmonad/`, `xmobar/`, `xresources/` — X11 window manager
  - `locations/` — geographic coordinates for redshift
- `overlays/` — nixpkgs overlays
- `pkgs/` — custom package definitions
- `inputs/neovim-plugins/` — sub-flake pinning neovim plugin sources

### Key Conventions

- **Feature aspects**: `den.aspects.<feature>.homeManager = <path-or-module>` in `modules/features/`
- **Per-host user config**: `den.aspects.jon.provides.<host>` contains host-specific includes and homeManager config
- **Host aspects**: `den.aspects.<host>.nixos` contains the NixOS/darwin system config
- **Custom builders**: Each host overrides `den.hosts.*.instantiate` to use appropriate nixpkgs (kepler: stable, newton/gaudi: unstable, planck: nixos-raspberrypi)
- **`outputs` let-binding**: Each `modules/hosts/<name>.nix` constructs `outputs = { nixosModules = import ../../lib/nixos; overlays = ...; }` and passes it as specialArgs to avoid circular reference
- **HM extraSpecialArgs**: Hosts pass `inputs` (for zsh/neovim plugins) and `outputs` (for common.nix signature) via `home-manager.extraSpecialArgs`
- **nixpkgs channels**: stable (`nixos-25.11`) for kepler/planck; `nixos-unstable` for gaudi/newton
- **Secrets**: `agenix` input; its NixOS module loaded on kepler
- **Formatter**: `alejandra` (run via `nix fmt`)
- **`_` prefix**: Files prefixed with `_` are ignored by import-tree (used for `_<host>-home.nix` HM modules)
