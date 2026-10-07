{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
  serena = inputs.mcp.serena.packages.${system}.serena;

  jsonFormat = pkgs.formats.json {};

  # Same pinned sources claude.nix uses, so both agents see identical skills.
  plugins = import ./skill-plugins.nix {inherit pkgs;};

  skillsDir = "${config.home.homeDirectory}/.agents/skills";

  # context-mode ships its CLI as a bundled script (bin.context-mode ->
  # ./cli.bundle.mjs in its package.json) meant to be `npm install -g`'d.
  # Wrap the same pinned checkout instead, so the mcp.json entry below (and
  # `npm:context-mode`'s own expectations) resolve without an imperative
  # global install.
  contextModeCli = pkgs.writeShellScriptBin "context-mode" ''
    exec ${pkgs.nodejs}/bin/node ${plugins.context-mode}/cli.bundle.mjs "$@"
  '';

  # pi discovers SKILL.md/agents/commands recursively under each linked repo.
  # The upstream repos bundle duplicate copies of their skills in
  # non-canonical dirs (caveman: plugins/, src/, benchmarks/; ponytail:
  # benchmarks/; context-mode: configs/), which produced the "Skill
  # conflicts" collisions at startup. Whitelist only the dirs that hold the
  # real skills/agents/commands so the duplicates are never discovered.
  #
  # - humanizer ships its SKILL.md at the repo root, so it has no entry here
  #   and is linked whole (below).
  # - context-mode is omitted from the skills map entirely: the
  #   `npm:context-mode` package (required for its native Pi extension)
  #   already provides the ctx-* skills under ~/.pi/agent/npm/node_modules,
  #   so linking them here too only created an unavoidable collision.
  #   contextModeCli above still uses the pinned ${plugins.context-mode}.
  skillSubdirs = {
    caveman = ["skills" "agents" "commands"];
    ponytail = ["skills" "commands"];
    mattpocock-skills = ["skills"];
    typesafe = ["skills"];
  };

  # Plugins linked whole (SKILL.md at root or no known duplicate dirs).
  wholeRepoPlugins = ["humanizer"];

  # Build a curated tree containing only the whitelisted subdirs. Copy real
  # directories (not symlinks) so pi's recursive SKILL.md walker discovers
  # them even if it does not follow nested directory symlinks.
  curate = name: src:
    pkgs.runCommand "pi-skills-${name}" {} ''
      mkdir -p "$out"
      ${lib.concatMapStringsSep "\n" (d: ''
        if [ -e "${src}/${d}" ]; then
          cp -rL --no-preserve=mode "${src}/${d}" "$out/${d}"
        fi
      '') skillSubdirs.${name}}
    '';

  piSkillLinks =
    lib.mapAttrs' (name: src:
      lib.nameValuePair "${skillsDir}/${name}" {
        source =
          if lib.elem name wholeRepoPlugins
          then src
          else curate name src;
      })
    (lib.filterAttrs (name: _:
      (skillSubdirs ? ${name}) || lib.elem name wholeRepoPlugins)
    plugins);
in {
  programs.pi-coding-agent = {
    enable = true;

    settings = {
      packages = [
        # Pi's own package manager installs/updates this at session start -
        # see https://github.com/GeneGulanesJr/LaPis (local SQLite memory,
        # no API keys or cloud service).
        "git:github.com/GeneGulanesJr/LaPis"
        # Registers context-mode's native Pi extension (tool_call,
        # tool_result, session_start, session_before_compact hooks) - see
        # https://github.com/mksglu/context-mode#pi-coding-agent. The
        # mcpServers entry below provides the MCP tools; contextModeCli
        # above provides the `context-mode` binary that entry's
        # command = "context-mode" needs on PATH.
        "npm:context-mode"
        # Vim-style modal editing in the prompt editor (INSERT/NORMAL/VISUAL),
        # see https://github.com/lajarre/pi-vim
        "npm:pi-vim"
      ];

      # No `extensions` entry: as of caveman v3.0.0, its pi-extension (which
      # used to register /ponytail* commands natively) is TypeScript source
      # under packages/pi-extension needing a build step, like
      # mattpocock/skills already was. Its skills still work via plain
      # SKILL.md discovery below, just without the native commands/status bar.
    };

    extraPackages = [contextModeCli];
  };

  # Pi recursively discovers SKILL.md files under ~/.agents/skills/, the
  # same shared Agent Skills location Claude Code's plugin dirs land in -
  # symlink the whole repo per plugin, mirroring claude.nix's approach.
  home.file =
    piSkillLinks
    // {
      "${config.programs.pi-coding-agent.configDir}/mcp.json".source = jsonFormat.generate "pi-coding-agent-mcp.json" {
        mcpServers = {
          serena = {
            command = "${serena}/bin/serena";
            args = ["start-mcp-server" "--context" "ide" "--project-from-cwd"];
          };
          context-mode.command = "context-mode";
        };
      };
    };
}
