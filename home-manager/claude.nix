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
    (["claude-code-home-manager"] ++ lib.attrNames plugins);
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
        PreToolUse = [
          {
            matcher = "";
            hooks = [
              {
                type = "command";
                command = "serena-hooks remind --client=claude-code";
              }
            ];
          }
          {
            matcher = "mcp__serena__*";
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
        "ruby-lsp@claude-plugins-official" = true;
        "superpowers@claude-plugins-official" = true;
        "tdd@mdodkins-tdd" = true;
        "typescript-lsp@claude-plugins-official" = true;
      };
      extraKnownMarketplaces = {
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
        command = "${serena}/bin/serena";
        args = [
          "start-mcp-server"
          "--context"
          "claude-code"
          "--project-from-cwd"
        ];
      };
    };

    agents = {
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

  home.file = lib.listToAttrs (map (entry:
    lib.nameValuePair "${workDir}/${entry}" {
      source = config.home.file."${config.programs.claude-code.configDir}/${entry}".source;
    })
  sharedConfigDirEntries);

  # ruby-lsp backs the ruby-lsp@claude-plugins-official plugin, which only
  # finds the server on PATH.
  home.packages = [serena pkgs.ruby-lsp statusline];
}
