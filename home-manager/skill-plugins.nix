# Shared skill/plugin sources used by both claude.nix and pi-coding-agent.nix,
# pinned once here so the two agents see identical content.
{pkgs}: {
  mattpocock-skills = pkgs.fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "v1.2.3";
    hash = "sha256-I/EXHGW92nXz6JCLp8SKGgzXrbbUTkLAfxv8bc/ThwQ=";
  };

  # typesafe-ai/skills: TypeSafe System One API context. Loaded as a
  # personal plugin (skills/agents/commands/hooks/MCP) the same way as the
  # other entries here - not through marketplace registration.
  typesafe = pkgs.fetchFromGitHub {
    owner = "typesafe-ai";
    repo = "skills";
    rev = "65a39f393687675ce170e6094757de20370365b9";
    hash = "sha256-Lh2Y90TFv+njKqo/g5WXEHw0Rk1jQSH5POqKtrvy5kM=";
  };

  # Rewrites AI-sounding prose. Skill only, no hooks or scripts.
  humanizer = pkgs.fetchFromGitHub {
    owner = "blader";
    repo = "humanizer";
    rev = "v3.1.0";
    hash = "sha256-n8cbTzhlGf8VnWpPukq7XD2mucIrqyE1XMpAAc5oA8A=";
  };

  # "Laziest senior dev" mode. node hooks; state lives in ~/.config/ponytail.
  ponytail = pkgs.fetchFromGitHub {
    owner = "DietrichGebert";
    repo = "ponytail";
    rev = "v4.10.0";
    hash = "sha256-PES5XrSYx0VBXWVHEDRykGy0SAmJfV/luzy8Gfg0aAQ=";
  };

  # Token-compressed output mode. node hooks; state in ~/.config/caveman.
  # Also ships a ready-to-run `pi-extension/` (registers /ponytail* commands
  # natively for Pi Coding Agent - see pi-coding-agent.nix).
  caveman = pkgs.fetchFromGitHub {
    owner = "JuliusBrussee";
    repo = "caveman";
    rev = "v3.0.0";
    hash = "sha256-XtrZSxw1Hv2+YAm+zMZSBY4uumLDSsRR0LgYwd6jKlg=";
  };

  # MCP server + hooks that cut context-window usage (sandboxed code exec,
  # FTS5 knowledge base, session continuity across compactions). Fully
  # self-contained for Claude Code (.claude-plugin/plugin.json declares its
  # own mcpServers/hooks/skills, served from this same checkout via
  # ${CLAUDE_PLUGIN_ROOT}). Pi needs extra wiring - see pi-coding-agent.nix
  # (settings.packages "npm:context-mode" for the native .pi/extensions hook,
  # plus a wrapped `context-mode` binary from this checkout's cli.bundle.mjs
  # for the mcp.json entry upstream's README asks for).
  context-mode = pkgs.fetchFromGitHub {
    owner = "mksglu";
    repo = "context-mode";
    rev = "v1.0.169";
    hash = "sha256-1pV56ZB2aqod+C0kb5myuiWLAJ7+opiaurwZZ3BGKYk=";
  };
}
