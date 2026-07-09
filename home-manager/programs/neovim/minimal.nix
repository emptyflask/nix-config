{
  inputs,
  pkgs,
  ...
}: let
  concatFiles = files:
    pkgs.lib.strings.concatMapStringsSep "\n" builtins.readFile files;
in
  with pkgs; {
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = false;

      initLua =
        concatFiles [./config.lua ./keymap.lua ./netrw.lua ./rename.lua];

      extraPackages = [lua-language-server nixd shfmt tree-sitter];

      plugins = pkgs.callPackage ./plugins.nix {
        inherit inputs;
        minimal = true;
      };
    };

    # all ftplugin configs:
    xdg.configFile."nvim/ftplugin/" = {
      source = ./ftplugin;
      recursive = true;
    };
  }
