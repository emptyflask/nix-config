{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
  serena = inputs.mcp.serena.packages.${system}.serena;

  plugins = {
    mattpocock-skills = pkgs.fetchFromGitHub {
      owner = "mattpocock";
      repo = "skills";
      rev = "v1.2.3";
      hash = "sha256-I/EXHGW92nXz6JCLp8SKGgzXrbbUTkLAfxv8bc/ThwQ=";
    };

    # Rewrites AI-sounding prose. Skill only, no hooks or scripts.
    humanizer = pkgs.fetchFromGitHub {
      owner = "blader";
      repo = "humanizer";
      rev = "e2e92e7b4b8229253ed5c8e81dc65463fdeddda5";
      hash = "sha256-n08pud3m9ka1Ymqv6qinSCUku975FM2LJRboi9ur5D4=";
    };

    # "Laziest senior dev" mode. node hooks; state lives in ~/.config/ponytail.
    ponytail = pkgs.fetchFromGitHub {
      owner = "DietrichGebert";
      repo = "ponytail";
      rev = "2ed6c52c9d7e5e56942508591085fd45dea277d3";
      hash = "sha256-bGdXvzhWPwGdz3T2Yh2h6lf+3PBRFAfdBxP5pESmCHI=";
    };

    # Token-compressed output mode. node hooks; state in ~/.config/caveman.
    caveman = pkgs.fetchFromGitHub {
      owner = "JuliusBrussee";
      repo = "caveman";
      rev = "2f49f0e1a352aa810e70056b7930aeb0b3d219b4";
      hash = "sha256-FagkzOnjW9tqeaAK8NX1X8REsjWRRMqfrvhByEtrAXM=";
    };
  };

  # Second config dir used for work (CLAUDE_CONFIG_DIR=~/.claude-work claude).
  workDir = "${config.home.homeDirectory}/.claude-work";

  sharedConfigDirEntries =
    map (name: "skills/${name}")
    (["claude-code-home-manager"] ++ lib.attrNames plugins);
in {
  programs.claude-code = {
    enable = true;
    package = inputs.claude-code.packages.${system}.default;
    inherit plugins;

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
  };

  home.file = lib.listToAttrs (map (entry:
    lib.nameValuePair "${workDir}/${entry}" {
      source = config.home.file."${config.programs.claude-code.configDir}/${entry}".source;
    })
  sharedConfigDirEntries);

  home.packages = [serena];
}
