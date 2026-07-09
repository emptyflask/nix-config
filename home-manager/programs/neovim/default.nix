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
      withNodeJs = true;
      withPython3 = false;
      withRuby = false;
      extraWrapperArgs = ["--suffix" "LD_LIBRARY_PATH" ":" "${stdenv.cc.cc.lib}/lib"];

      extraConfig = ''
        let g:dictionary = "${scowl}/share/dict/words.txt"

        function! UUID()
          return system('${util-linux}/bin/uuidgen')[0:-2]
        endfunction
      '';

      initLua = concatFiles [
        ./config.lua
        ./haskell.lua
        ./keymap.lua
        ./netrw.lua
        ./rename.lua
      ];

      extraPackages = [
        biome
        # dhall-lsp-server
        haskellPackages.haskell-language-server
        lua-language-server
        luaPackages.tiktoken_core
        # nil # nix language server
        nixd # other nix language server
        ruby-lsp
        rust-analyzer
        shfmt
        solargraph
        terraform-ls
        tree-sitter
        typescript
        typescript-language-server
      ];

      plugins = pkgs.callPackage ./plugins.nix {inherit inputs;};
    };

    # all ftplugin configs:
    xdg.configFile."nvim/ftplugin/" = {
      source = ./ftplugin;
      recursive = true;
    };
  }
