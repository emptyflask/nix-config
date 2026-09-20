# nix-config

## Machines

| Host    | What it is                           | System            |
|---------|--------------------------------------|-------------------|
| kepler  | Desktop (NixOS)                      | x86_64-linux      |
| newton  | 2012 MacBook server (NixOS)          | x86_64-linux      |
| planck  | Raspberry Pi 4 (NixOS)               | aarch64-linux     |
| gaudi   | M2 MacBook Pro (nix-darwin)          | aarch64-darwin    |

kepler runs Jellyfin, Immich, and Postgres for itself, at least until I have a
NAS capable of doing it. newton runs the rest of the homelab: Paperless,
Hermes, Navidrome, Hister, AdGuard, Audiobookshelf. planck is mostly step-ca
(acting as the LAN's internal CA) and a secondary AdGuard. gaudi is just
home-manager plus a handful of darwin system defaults.

## Rebuilding a machine

Everything goes through the flake, and `nh` wraps `nixos-rebuild` /
`darwin-rebuild` so you get a nicer diff and generation output.

```sh
nh os switch                          # rebuild the machine you're on
nh os switch --flake .#kepler         # rebuild a specific host
```

For the boxes I'm not sitting at, there are aliases (defined in
`hosts/kepler/home.nix`) that deploy over SSH:

```sh
deploy-kepler   # nh os switch
deploy-newton   # nh os switch -H newton --target-host jon@newton.lan -e passwordless
deploy-planck   # nh os switch -H planck --target-host jon@planck.lan -e passwordless
```

gaudi isn't a NixOS host, so it goes through nix-darwin's own switch
instead:

```sh
darwin-rebuild switch --flake .#gaudi
```

## Home-manager on its own

gaudi's user environment is a standalone home-manager configuration rather
than the NixOS-integrated module, since darwin support here is minimal:

```sh
home-manager switch --flake .#jon@gaudi
```

On kepler, newton, and planck, home-manager is wired in through the NixOS
module in `outputs.nix`, so it comes along for free with `nh os switch`
(no separate `home-manager switch` needed).

## Everything else in here

- `pkgs/` - custom packages, built with `nix build .#<name>` and pulled in
  automatically via the overlay in `overlays/`.
- `modules/` - reusable NixOS and home-manager modules shared across hosts.
- `secrets/` - agenix-encrypted secrets, decrypted at activation time.
- `inputs/` - a few flake inputs I maintain myself (`mcp`,
  `neovim-plugins`, `livesync-cli`) that live in this repo instead of
  their own.
- `nix fmt` - formats all the `.nix` files with alejandra.

## Adding a new host

Copy the shape of an existing one under `hosts/`, add it to
`nixosConfigurations` (or `darwinConfigurations`) in `outputs.nix`, wire up
its `home.nix` the same way the others do, and it's rebuildable the same
way as everything else here.
