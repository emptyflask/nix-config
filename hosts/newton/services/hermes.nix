{
  config,
  inputs,
  pkgs,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;

  # Dependency groups the agent's venv is built with. The hermes-agent module
  # bakes these into the package it runs. The webui runs the agent host-native
  # from its own package reference (HERMES_WEBUI_PYTHON = the venv's python3), so
  # it must be built with the SAME groups — honcho in particular, since
  # settings.memory.provider = "honcho" fails at runtime without it.
  dependencyGroups = ["firecrawl" "hindsight" "honcho" "messaging"];

  # Pinned Python libraries baked into the sealed venv (reproducible). Add
  # nixpkgs libs here for anything you want guaranteed/offline-buildable;
  # arbitrary PyPI libs the agent grabs on the fly go to the lazy-install vendor
  # dir instead (HERMES_LAZY_INSTALL_TARGET, set below). Skips libs hermes already
  # bundles as core deps (requests, httpx, rich, Pillow, markdown, pydantic, …).
  extraPythonPackages = with pkgs.python3Packages; [
    beautifulsoup4
    lxml # HTML/XML scraping + parsing (lxml is compiled)
    numpy
    openpyxl # PDF text extraction + Excel .xlsx read/write
    pandas # numbers + tabular data; compiled, so Nix avoids fragile wheels on this CPU
    pypdf
    python-dateutil
    tabulate # flexible date parsing + text/markdown table formatting
  ];

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
      mcpVault = {
        command = "npx";
        args = ["@bitbonsai/mcpvault@latest" config.services.livesync-cli.vaultPath];
      };
      # PAPERLESS_API_KEY resolved at runtime from hermes-env (mirrors HISTER_ACCESS_TOKEN
      # above) -- add a line `PAPERLESS_API_KEY=<token>` to secrets/hermes.env.age via
      # `agenix -i ~/.ssh/id_agenix -e secrets/hermes.env.age`. Generate the token in
      # Paperless-ngx: My Profile -> API Auth Token.
      paperless = {
        command = "npx";
        args = ["-y" "@baruchiro/paperless-mcp@latest"];
        env = {
          PAPERLESS_URL = "http://127.0.0.1:28981";
          PAPERLESS_API_KEY = "\${PAPERLESS_API_KEY}";
        };
      };
    };
    extraDependencyGroups = dependencyGroups;
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
    # Vendor dir for HERMES_LAZY_INSTALL_TARGET (runtime uv pip installs). setgid
    # + group-writable so the gateway, webui, and dashboard (all run as hermes)
    # share one target. The plugin also mkdirs it, but seed it with correct perms.
    "d /var/lib/hermes/lazy-deps 2770 hermes hermes - -"
  ];
}
