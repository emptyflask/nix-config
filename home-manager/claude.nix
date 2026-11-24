{
  config,
  lib,
  pkgs,
  inputs,
  self,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
  serena = inputs.mcp.serena.packages.${system}.serena;

  # Run Serena inside the project's direnv environment so language servers
  # see the dev shell's toolchain. Without it, ruby-lsp runs under the system
  # ruby, `bundle exec ruby-lsp` can't find the project's gems, and Serena then
  # tries `gem install` into the read-only store. Falls back to plain Serena
  # where there's no .envrc or it isn't allowed (direnv exec fails outright).
  serena-direnv = pkgs.writeShellScript "serena-direnv" ''
    if ${pkgs.direnv}/bin/direnv exec . true >/dev/null 2>&1; then
      exec ${pkgs.direnv}/bin/direnv exec . ${serena}/bin/serena "$@"
    fi
    exec ${serena}/bin/serena "$@"
  '';

  # Shared with pi-coding-agent.nix so both agents see identical skill
  # content. Claude Code owns known_marketplaces.json itself
  # (installLocation/lastUpdated get rewritten at runtime for
  # claude-plugins-official/mdodkins-tdd), so we deliberately don't manage
  # that file from nix.
  plugins = import ./skill-plugins.nix {inherit pkgs;};

  # Second config dir used for work (CLAUDE_CONFIG_DIR=~/.claude-work claude).
  workDir = "${config.home.homeDirectory}/.claude-work";

  # On PATH rather than referenced by store path so the work config dir's
  # unmanaged settings.json can point at it too.
  statusline = pkgs.writeShellApplication {
    name = "claude-statusline";
    runtimeInputs = [pkgs.jq pkgs.git];
    # The ANSI color codes are deliberately spliced into printf format strings.
    excludeShellChecks = ["SC2059"];
    text = builtins.readFile ./claude-statusline.sh;
  };

  sharedConfigDirEntries =
    ["CLAUDE.md"]
    ++ map (name: "skills/${name}")
    (["claude-code-home-manager"] ++ lib.attrNames plugins)
    ++ map (name: "agents/${name}.md") (lib.attrNames config.programs.claude-code.agents);
in {
  age.secrets.typesafe-api-key.file = "${self}/secrets/typesafe-api-key.age";

  programs.zsh.initContent = lib.mkAfter ''
    export TYPESAFE_API_KEY="$(${pkgs.coreutils}/bin/cat ${config.age.secrets.typesafe-api-key.path} 2>/dev/null)"
  '';

  programs.claude-code = {
    enable = true;
    package = inputs.claude-code.packages.${system}.default;
    inherit plugins;

    # Imported verbatim from the live ~/.claude/settings.json so this doesn't
    # clobber it - enabledPlugins/extraKnownMarketplaces here track plugins
    # installed the native `claude plugin install` way (separate from the
    # `plugins` option above). Update this by hand to match if you install
    # or remove one of those imperatively.
    settings = {
      permissions = {
        defaultMode = "auto";
      };
      hooks = {
        # No `serena-hooks remind`: it denies grep/Read bursts outright, which
        # just costs a retry since Serena's deferred tools rarely get loaded.
        PreToolUse = [
          {
            # home-manager wraps mcpServers in its "hm" plugin, so the tools
            # are mcp__plugin_hm_serena__*, not mcp__serena__*
            matcher = "mcp__plugin_hm_serena__.*";
            hooks = [
              {
                type = "command";
                command = "serena-hooks auto-approve --client=claude-code";
              }
            ];
          }
        ];
        SessionStart = [
          {
            matcher = "";
            hooks = [
              {
                type = "command";
                command = "serena-hooks activate --client=claude-code";
              }
            ];
          }
        ];
        SessionEnd = [
          {
            matcher = "";
            hooks = [
              {
                type = "command";
                command = "serena-hooks cleanup --client=claude-code";
              }
            ];
          }
        ];
      };
      enabledPlugins = {
        "pstack@cursor-plugins" = true;
        "ruby-lsp@claude-plugins-official" = true;
        "superpowers@claude-plugins-official" = true;
        "tdd@mdodkins-tdd" = true;
        "typescript-lsp@claude-plugins-official" = true;
      };
      extraKnownMarketplaces = {
        cursor-plugins = {
          source = {
            source = "github";
            repo = "cursor/plugins";
          };
        };
        mdodkins-tdd = {
          source = {
            source = "github";
            repo = "mdodkins/claude-tdd-skill";
          };
        };
      };
      statusLine = {
        type = "command";
        command = "claude-statusline";
      };
      tui = "fullscreen";
      editorMode = "vim";
      disableMouseClicks = true;
      autoMode = {
        environment = [
          "### Org-wide"
          "**Organization**: None configured"
          "**Cloud provider(s)**: None configured"
          "**Repository visibility**: private (emptyflask/nix-config, via gh)"
          "**Internal sharing / snippet hosting**: None configured — treat public paste/gist services as outside the trust boundary"
          "**Secrets management**: agenix (age-encrypted secrets file `secrets.nix` present in repo)"
          "**Default / protected branches**: Default branch `main`; no rulesets or protected branches listed by gh"
          "**CI/CD deploy targets**: None configured"
          "**Network posture**: None configured"
          "**Host containment**: None configured — assume Claude Code runs on an ordinary developer machine or CI runner with open internet"
          "**Source control**: The trusted repo (github.com:emptyflask/nix-config.git) and its remote(s) only (no additional orgs configured)"
          "**Trusted internal domains**: None configured"
          "**Trusted cloud buckets**: None configured"
          "**Key internal services**: hister.newton.lan (contacted host in this project's transcripts, likely a local/personal infra host)"
          "**Internal package registry**: None configured"
          "**Sensitive data locations & audiences**: secrets.nix (agenix-encrypted secrets), home-manager/xmonad/.envrc — share only with audiences cleared at the [named+specifics] bar"
          "**Data retention / declassification**: None configured"
          "**Sensitive remote targets**: any namespace, host, or container whose name carries `prod` or `production` as a whole word or name segment"
          "**Protected deployment namespaces / environments**: None configured — fall back to the Sensitive remote targets heuristic"
          "**Protected IaC scopes**: IAM, RBAC, networking, quota, and node-pool resources; anything whose name or tag carries `prod` or `production` as a whole word or name segment"
          "### User-specific"
          "**Primary use of Claude Code**: personal NixOS system configuration (hobby/personal posture)"
          "**Trusted repo**: /home/jon/dev/nix-config (github.com:emptyflask/nix-config.git, private) — routine work under this repo is trusted"
          "**Org-specific CLIs**: nix, nix-instantiate, nix-build, nixos-rebuild, nh, agenix, home-manager tooling — used routinely in this project"
        ];
        allow = [
          "$defaults"
          "Bash(nix flake check:*) in /home/jon/dev/nix-config"
          "Bash(nixos-rebuild switch:*) in /home/jon/dev/nix-config"
          "Bash(nh os switch:*) in /home/jon/dev/nix-config"
        ];
        soft_deny = [
          "$defaults"
          "Bash(agenix -e:*) — editing/decrypting secrets.nix"
        ];
      };
    };

    mcpServers = {
      serena = {
        type = "stdio";
        command = "${serena-direnv}";
        args = [
          "start-mcp-server"
          "--context"
          "claude-code"
          "--project-from-cwd"
        ];
      };
    };

    # Picked from emptyflask/awesome-claude-code-subagents (flake input);
    # bump with `nix flake update claude-subagents`.
    agents =
      lib.concatMapAttrs (category: names:
        lib.genAttrs names (name: "${inputs.claude-subagents}/categories/${category}/${name}.md"))
      {
        "01-core-development" = ["backend-developer" "frontend-developer"];
        "02-language-specialists" = ["nix-expert" "rails-expert"];
        "03-infrastructure" = ["devops-engineer"];
        "04-quality-security" = [
          "architect-reviewer"
          "code-reviewer"
          "compliance-auditor"
          "debugger"
          "performance-engineer"
          "qa-expert"
          "security-auditor"
          "test-automator"
        ];
        "08-business-product" = ["product-manager"];
      };

    # Serena's tools are deferred behind ToolSearch, so without a standing
    # instruction Claude defaults to grep/Read and never reaches for them.
    context = ''
      ## Code navigation

      Prefer Serena's MCP tools for symbol-level work in any language Serena
      supports. Use `find_symbol` and `get_symbols_overview` to locate
      definitions, `find_referencing_symbols` for callers and usages, and
      `rename_symbol`, `replace_symbol_body` and `insert_*_symbol` for
      structural edits. They're deferred, so load them with ToolSearch
      ("serena") before first use. Fall back to grep/Read for non-code text,
      config, string literals, or when Serena comes back empty.
    '';
  };

  home.file =
    lib.listToAttrs (map (entry:
      lib.nameValuePair "${workDir}/${entry}" {
        source = config.home.file."${config.programs.claude-code.configDir}/${entry}".source;
      })
    sharedConfigDirEntries)
    # home-manager's plugin wrapper is a dir of top-level symlinks into the
    # source, and Claude Code (>= 2.1.3xx) rejects manifest skills/hooks paths
    # that resolve outside the plugin dir ("path escapes plugin directory").
    # Replace each wrapper with a dereferenced copy, keeping its generated
    # plugin.json for sources that don't ship one.
    // lib.mapAttrs' (name: src:
      lib.nameValuePair "${config.programs.claude-code.configDir}/skills/${name}" {
        source = lib.mkForce (pkgs.runCommand "claude-code-${name}-real" {} ''
          cp -rL ${src} "$out"
          chmod -R u+w "$out"
          if [[ ! -e $out/.claude-plugin/plugin.json ]]; then
            mkdir -p "$out/.claude-plugin"
            echo '${builtins.toJSON {inherit name;}}' > "$out/.claude-plugin/plugin.json"
          fi
        '');
      })
    plugins;

  # ruby-lsp backs the ruby-lsp@claude-plugins-official plugin, which only
  # finds the server on PATH.
  home.packages = [serena pkgs.python3 pkgs.ruby-lsp statusline];
}
