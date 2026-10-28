{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;

  # Python package set matching hermes's own interpreter (pinned by its
  # pm/lock.json, from its own nixpkgs). Must be used for extraPythonPackages:
  # the package's requiredPythonModules silently drops anything built against
  # a different python (e.g. pkgs.python3Packages), leaving it off PYTHONPATH.
  pyPkgs = inputs.hermes-agent.packages.${system}.default.python.pkgs;

  # Dependency groups the agent's venv is built with. The hermes-agent module
  # bakes these into the package it runs. The webui runs the agent host-native
  # from its own package reference (HERMES_WEBUI_PYTHON = the venv's python3), so
  # it must be built with the SAME groups.
  #
  # "hindsight" and "honcho" used to live here too, but upstream moved every
  # non-builtin memory provider out of pyproject.toml's extras/dependency-groups
  # and into its runtime plugin catalog (installed to $HERMES_HOME/plugins/<name>,
  # not the sealed venv) — passing either name here now fails the build with
  # "Extra/group name '<name>' does not match either extra or dependency group".
  # We still use "hindsight" as memory.provider below; it's declared via
  # extraPlugins instead (pinned from the catalog entry, see hindsightPlugin).
  dependencyGroups = ["firecrawl" "messaging"];

  # The "hindsight" memory provider's catalog entry
  # (plugin-catalog/hindsight.yaml upstream): the actual Hermes plugin
  # (plugin.yaml + __init__.py) lives in a subdir of vectorize-io/hindsight,
  # not at the repo root, so pull just that subdir out into its own derivation
  # for extraPlugins below. Bump both `rev` and `version` together from that
  # catalog entry when updating.
  hindsightSrc = pkgs.fetchFromGitHub {
    owner = "vectorize-io";
    repo = "hindsight";
    rev = "d56c4acdf59c41957613d399094cdf8c489b060c"; # version 1.2.1
    hash = "sha256-L5HjVF64foSslizP6FPvEcnzorK4LY78YnuuP8rfEcA=";
  };
  hindsightPlugin = pkgs.runCommand "hermes-plugin-hindsight" {} ''
    cp -r ${hindsightSrc}/hindsight-integrations/hermes $out
  '';

  # The plugin's pyproject.toml deps (hindsight-client/-embed >=0.10.1,<1).
  # Hermes would uv-sync these into its venv on install, which can't work on the
  # read-only store venv, so bake them in via extraPythonPackages instead. Not in
  # nixpkgs; both are pure-Python wheels. Keep below 1.0 to match the plugin pin.
  # Their deps (aiohttp, pydantic, rich, yarl, …) already live in the sealed
  # venv, and hermes's build fails on any extra that duplicates a venv package,
  # so propagate nothing and skip the runtime-deps check (it can't see the venv).
  # aiohttp-retry is the one dep the venv lacks; it's stripped the same way.
  bareWheel = pname: version: hash:
    pyPkgs.buildPythonPackage {
      inherit pname version;
      format = "wheel";
      dontCheckRuntimeDeps = true;
      src = pyPkgs.fetchPypi {
        inherit version hash;
        pname = builtins.replaceStrings ["-"] ["_"] pname;
        format = "wheel";
        dist = "py3";
        python = "py3";
      };
    };
  hindsightClient = bareWheel "hindsight-client" "0.10.3" "sha256-tNDRu8KdzU7yWkojoIpIBG1TN7cEva+rsC0AENKZoGg=";
  hindsightEmbed = bareWheel "hindsight-embed" "0.10.3" "sha256-KQuB2DY+mW8Wb1M9MsYec0r10QRpWiUrDg9ynPNuzPE=";
  aiohttpRetry = bareWheel "aiohttp-retry" "2.9.1" "sha256-ZtJ1nRkhg4JWoFo/gK1+ckk28IPjW+WrteFu7Wvm3FQ=";

  # Python libraries added to the agent's PYTHONPATH. Must come from pyPkgs, and
  # must not (transitively) include anything already in the sealed venv — the
  # build fails on collisions — so prefer bareWheel and let the venv supply deps.
  extraPythonPackages = [aiohttpRetry hindsightClient hindsightEmbed];

  # Reproduces exactly the package the hermes-agent module builds internally
  # (default.override { inherit extraDependencyGroups extraPythonPackages; }), so
  # the agent service, webui, and dashboard all share ONE venv in the store
  # instead of drifting — the webui/dashboard run the agent host-native from this
  # same reference, so they must be built with identical groups + python libs.
  hermesAgentPkg = inputs.hermes-agent.packages.${system}.default.override {
    extraDependencyGroups = dependencyGroups;
    inherit extraPythonPackages;
  };
in {
  age.secrets.hermes-env.file = ../../../secrets/hermes.env.age;
  age.secrets.hermes-webui-env.file = ../../../secrets/hermes-webui.env.age;

  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;
    environmentFiles = [config.age.secrets.hermes-env.path];
    mcpServers = {
      atlassian = {
        url = "https://mcp.atlassian.com/v1/mcp/authv2";
        auth = "oauth";
      };
      hister = {
        url = "http://127.0.0.1:4433/mcp";
        headers.Authorization = "Bearer \${HISTER_ACCESS_TOKEN}";
        timeout = 180;
      };
      # Absolute npx paths: hermes swaps a bare "npx" for its own PM-provisioned
      # copy, and that provisioning hangs on NixOS — blocking the shared MCP loop
      # so every server (HTTP ones too) dies with CancelledError. An absolute
      # command is left as-is.
      mcpVault = {
        command = "${pkgs.nodejs}/bin/npx";
        args = ["@bitbonsai/mcpvault@latest" config.services.livesync-cli.vaultPath];
      };
      # PAPERLESS_API_KEY resolved at runtime from hermes-env (mirrors HISTER_ACCESS_TOKEN
      # above) -- add a line `PAPERLESS_API_KEY=<token>` to secrets/hermes.env.age via
      # `agenix -i ~/.ssh/id_agenix -e secrets/hermes.env.age`. Generate the token in
      # Paperless-ngx: My Profile -> API Auth Token.
      paperless = {
        command = "${pkgs.nodejs}/bin/npx";
        args = ["-y" "@baruchiro/paperless-mcp@latest"];
        env = {
          PAPERLESS_URL = "http://127.0.0.1:28981";
          PAPERLESS_API_KEY = "\${PAPERLESS_API_KEY}";
        };
      };
    };
    extraDependencyGroups = dependencyGroups;
    # Not extraPlugins: that links plugins as nix-managed-<name>, but memory
    # providers resolve by directory name (plugins/hindsight), so memory.provider
    # wouldn't find it and startup would try a catalog install instead. Linked
    # via tmpfiles below.
    # CLI tools on the agent's PATH. uv is here so hermes's lazy-install ladder
    # (resolve_uv() or shutil.which("uv")) can find it; the nixpkgs uv is
    # patchelf'd for NixOS, unlike hermes's download-a-standalone-binary
    # fallback. python3 here is a general-purpose interpreter; Python *libraries*
    # come from extraPythonPackages (pinned) or the lazy-install vendor dir below.
    extraPackages = with pkgs; [imagemagick jq nodejs pandoc poppler-utils python3 ruby uv];

    # Pinned Python libraries (defined in the let above so hermesAgentPkg — the
    # webui/dashboard's package — stays in sync with the agent's venv).
    inherit extraPythonPackages;

    # Runtime "vendor directory" for arbitrary PyPI libs the agent installs on
    # the fly. hermes runs `uv pip install --target $HERMES_LAZY_INSTALL_TARGET`
    # here (writable, persistent), then appends it to sys.path — the sealed venv
    # still wins collisions. Sidesteps the read-only /nix/store venv. The dir is
    # ABI-stamped, so a Python bump on rebuild auto-invalidates and repopulates.
    environment.HERMES_LAZY_INSTALL_TARGET = "/var/lib/hermes/lazy-deps";

    settings = {
      memory.provider = "hindsight";
      model.default = "deepseek/deepseek-v4-flash-0731";
      auxiliary.vision = {
        model = "google/gemini-2.5-flash-lite";
        provider = "openrouter";
      };
    };
  };

  services.hermes-webui = {
    enable = true;
    host = "127.0.0.1";
    port = 8787;
    stateDir = "/var/lib/hermes-webui";
    user = "hermes";
    group = "hermes";
    hermesHome = "/var/lib/hermes/.hermes";
    agent.package = hermesAgentPkg;
    environmentFiles = [config.age.secrets.hermes-webui-env.path];
  };

  users.users = {
    hermes.linger = true;
    jon.extraGroups = ["hermes"];
  };

  # Upstream sets HERMES_HOME to 2770 (activation + a tmpfiles "d" rule), but
  # gateway discovery only accepts a group-writable home when the group is
  # private — jon's membership above makes it shared, so cron fails with
  # unsafe_control_permissions. Every hermes service runs as the hermes user,
  # so nothing needs group-write on the home itself (subdirs keep it).
  # Both upstream paths need overriding: activation (every switch) and tmpfiles
  # (boot, or a switch that changes tmpfiles config).
  system.activationScripts.hermes-home-perms = lib.stringAfter ["hermes-agent-setup"] ''
    chmod 2750 /var/lib/hermes/.hermes
  '';
  # tmpfiles applies the entry from the lexically first file per path, and
  # "00-hermes-home" sorts before the module's "00-nixos", so this one wins.
  systemd.tmpfiles.settings."00-hermes-home"."/var/lib/hermes/.hermes".d = {
    mode = "2750";
    user = "hermes";
    group = "hermes";
  };

  # hermes's cron worker needs a reachable user D-Bus session
  # (systemd-run --user --scope) for restart-safe scoping. `linger` above
  # makes that session exist, but user@<uid>.service starts in parallel with
  # multi-user.target, so on a fresh boot/restart hermes-agent can win the
  # race and log one failed cron dispatch before its own 60s retry recovers.
  # Wait for the bus socket first so the race never happens.
  systemd.services.hermes-agent.preStart = ''
    for i in $(seq 1 30); do
      [ -S "/run/user/$(id -u)/bus" ] && exit 0
      sleep 1
    done
    echo "warning: hermes user D-Bus session not ready after 30s" >&2
  '';

  # Hermes reads its persona from $HERMES_HOME/SOUL.md. In native mode
  # HERMES_HOME = /var/lib/hermes/.hermes (created by the hermes-agent module's
  # tmpfiles rules). Symlink the persona to the store copy — /nix/store is
  # readable, so the link resolves and the persona updates on every rebuild.
  systemd.tmpfiles.rules = [
    "L+ /var/lib/hermes/.hermes/SOUL.md - - - - ${./hermes/SOUL.md}"
    "L+ /var/lib/hermes/.hermes/plugins/hindsight - - - - ${hindsightPlugin}"
    # Vendor dir for HERMES_LAZY_INSTALL_TARGET (runtime uv pip installs). setgid
    # + group-writable so the gateway, webui, and dashboard (all run as hermes)
    # share one target. The plugin also mkdirs it, but seed it with correct perms.
    "d /var/lib/hermes/lazy-deps 2770 hermes hermes - -"
  ];
}
