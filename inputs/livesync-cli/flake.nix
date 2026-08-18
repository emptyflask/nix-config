{
  description = "self-hosted-livesync-cli — headless CouchDB sync for Obsidian LiveSync vaults";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    # The upstream repo, pinned to a release tag. `flake = false` means the flake
    # lockfile pins the source hash for us — no manual `src` hash to maintain.
    livesync-src = {
      url = "github:vrtmrz/obsidian-livesync/1.0.15";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, livesync-src }:
    let
      # The package builder, reused across systems.
      mkLivesyncCli = pkgs:
        let
          nodejs = pkgs.nodejs_22;
        in
        pkgs.buildNpmPackage {
          pname = "livesync-cli";
          version = "1.0.15";

          src = livesync-src;
          inherit nodejs;

          # ---- npm dependency cache (FOD) --------------------------------------
          # Hash of all npm deps from package-lock.json at tag 1.0.15. If you bump
          # the source, recompute with:
          #   nix run nixpkgs#prefetch-npm-deps -- <checkout>/package-lock.json
          npmDepsHash = "sha256-cbj/1XPy3blBpXsogmj7stez4X00lYzOu0sIrio3GQw=";

          # Don't run install scripts during `npm ci`: the root devDependencies
          # `edgedriver` and `geckodriver` download browser drivers from the
          # network on postinstall, which fails in the Nix sandbox. We rebuild the
          # one native addon we actually need (leveldown) explicitly below.
          npmFlags = [ "--ignore-scripts" ];

          # python3 + a C/C++ toolchain (from stdenv) to compile leveldown.
          # patchelf/makeWrapper for fixing the esbuild binary and wrapping the CLI.
          nativeBuildInputs = [ pkgs.python3 pkgs.makeWrapper pkgs.patchelf ];
          buildInputs = [ pkgs.stdenv.cc.cc.lib ];

          preBuild = ''
            # vite uses esbuild, whose prebuilt Go binary needs the NixOS dynamic
            # loader. Patch it and point esbuild's JS wrapper straight at it so it
            # doesn't try to re-resolve/download.
            esbuildBin=$PWD/node_modules/@esbuild/linux-x64/bin/esbuild
            if [ -f "$esbuildBin" ]; then
              # The esbuild binary is a statically-linked Go binary (no .interp),
              # so it runs on NixOS unpatched. Only fix the interpreter if it turns
              # out to be dynamically linked.
              if patchelf --print-interpreter "$esbuildBin" >/dev/null 2>&1; then
                patchelf --set-interpreter "$(cat "$NIX_CC/nix-support/dynamic-linker")" "$esbuildBin"
              fi
              export ESBUILD_BINARY_PATH="$esbuildBin"
            fi

            # leveldown ships prebuilt binaries that aren't linked for NixOS.
            # Remove them so node-gyp-build compiles from source against this
            # toolchain instead.
            rm -rf node_modules/leveldown/prebuilds
            npm rebuild leveldown --foreground-scripts
          '';

          # Build only the CLI workspace (the default `npm run build` builds the
          # Obsidian plugin, not the CLI).
          buildPhase = ''
            runHook preBuild
            npm run build --workspace self-hosted-livesync-cli
            runHook postBuild
          '';

          # The vite build externalizes pouchdb-*/werift/chokidar, so the runtime
          # needs the (hoisted, root) node_modules alongside dist/index.cjs. Node's
          # module resolution walks up from dist/ to this node_modules.
          installPhase = ''
            runHook preInstall

            mkdir -p $out/lib/livesync-cli
            cp -r node_modules            $out/lib/livesync-cli/node_modules
            cp -r src/apps/cli/dist       $out/lib/livesync-cli/dist

            # npm creates workspace self-symlinks in node_modules (e.g.
            # self-hosted-livesync-cli -> src/apps/cli). Those source dirs aren't
            # part of the runtime output, leaving dangling symlinks that fail the
            # noBrokenSymlinks check. The bundle doesn't need them, so drop any
            # broken symlinks.
            find $out/lib/livesync-cli/node_modules -xtype l -delete

            mkdir -p $out/bin
            makeWrapper ${nodejs}/bin/node $out/bin/livesync-cli \
              --add-flags $out/lib/livesync-cli/dist/index.cjs \
              --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib ]}

            runHook postInstall
          '';

          # index.cjs is a bundle; there's nothing meaningful to `require()`-test
          # beyond it starting, and it needs args to do anything.
          dontNpmPrune = true;

          meta = with pkgs.lib; {
            description = "Headless CLI for Self-hosted LiveSync (Obsidian) — CouchDB sync without Obsidian";
            homepage = "https://github.com/vrtmrz/obsidian-livesync/tree/main/src/apps/cli";
            license = licenses.mit;
            mainProgram = "livesync-cli";
            platforms = [ "x86_64-linux" ]; # esbuild/leveldown handling below assumes linux-x64
          };
        };
    in
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        packages.default = mkLivesyncCli pkgs;
        packages.livesync-cli = mkLivesyncCli pkgs;
        apps.default = {
          type = "app";
          program = "${mkLivesyncCli pkgs}/bin/livesync-cli";
        };
      })
    // {
      # ---- NixOS module: run the bidirectional sync daemon as a service --------
      nixosModules.default = { config, lib, pkgs, ... }:
        let
          cfg = config.services.livesync-cli;
        in
        {
          options.services.livesync-cli = {
            enable = lib.mkEnableOption "Self-hosted LiveSync headless sync daemon";

            package = lib.mkOption {
              type = lib.types.package;
              default = mkLivesyncCli pkgs;
              description = "The livesync-cli package to use.";
            };

            databasePath = lib.mkOption {
              type = lib.types.path;
              default = "/var/lib/livesync/db";
              description = "Directory holding the local PouchDB data (the .livesync folder).";
            };

            vaultPath = lib.mkOption {
              type = lib.types.path;
              example = "/srv/vault";
              description = "Directory of actual .md files that hermes reads/writes.";
            };

            settingsFile = lib.mkOption {
              type = lib.types.str;
              example = "/var/lib/livesync/settings.json";
              description = ''
                Path to the LiveSync settings JSON (contains the CouchDB URL and the
                E2EE passphrase). Pass a path that exists on the host — do NOT put a
                store path here, or your passphrase lands in the world-readable Nix
                store. Provision it out of band (agenix/sops-nix, or a 0600 file).
              '';
            };

            interval = lib.mkOption {
              type = lib.types.nullOr lib.types.ints.positive;
              default = null;
              description = "Poll CouchDB every N seconds instead of using the live _changes feed. null = live mode.";
            };

            user = lib.mkOption {
              type = lib.types.str;
              default = "livesync";
              description = "User to run the daemon as.";
            };

            group = lib.mkOption {
              type = lib.types.str;
              default = "livesync";
              description = "Group to run the daemon as.";
            };
          };

          config = lib.mkIf cfg.enable {
            # Create the default service user/group for you. If you point the
            # daemon at a user you already manage (e.g. to share files with
            # another service), we leave user/group management to you.
            users.users = lib.mkIf (cfg.user == "livesync") {
              livesync = {
                isSystemUser = true;
                group = cfg.group;
                home = "/var/lib/livesync";
              };
            };
            users.groups = lib.mkIf (cfg.group == "livesync") { livesync = { }; };

            systemd.services.livesync-cli = {
              description = "Self-hosted LiveSync headless sync daemon";
              wantedBy = [ "multi-user.target" ];
              after = [ "network-online.target" ];
              wants = [ "network-online.target" ];

              serviceConfig = {
                ExecStart = lib.concatStringsSep " " ([
                  "${cfg.package}/bin/livesync-cli"
                  cfg.databasePath
                  "--settings" cfg.settingsFile
                  "--vault" cfg.vaultPath
                ] ++ lib.optionals (cfg.interval != null) [ "--interval" (toString cfg.interval) ]);

                User = cfg.user;
                Group = cfg.group;
                Restart = "on-failure";
                RestartSec = 10;

                StateDirectory = "livesync";
                # Hardening (relax if it conflicts with your vault path).
                ProtectSystem = "strict";
                ProtectHome = true;
                ReadWritePaths = [ cfg.databasePath cfg.vaultPath ];
                PrivateTmp = true;
                NoNewPrivileges = true;
              };
            };
          };
        };
    };
}
