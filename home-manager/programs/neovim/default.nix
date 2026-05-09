{ inputs, pkgs, ... }:

let
  concatFiles = files:
    pkgs.lib.strings.concatMapStringsSep "\n" builtins.readFile files;

in with pkgs;

{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = false;
    withNodeJs = true;

    extraConfig = ''
      let g:dictionary = "${scowl}/share/dict/words.txt"

      function! UUID()
        return system('${util-linux}/bin/uuidgen')[0:-2]
      endfunction
    '';

    initLua = (concatFiles [
      ./config.lua
      ./haskell.lua
      ./keymap.lua
      ./netrw.lua
      ./rename.lua
    ]);

    extraPackages = [
      biome
      # dhall-lsp-server
      haskellPackages.haskell-language-server
      lua-language-server
      luaPackages.tiktoken_core
      # nil # nix language server
      nixd # other nix language server
      nodePackages.typescript
      nodePackages.typescript-language-server
      rust-analyzer
      shfmt
      solargraph
      ruby-lsp
      terraform-ls
      tree-sitter
    ];

    plugins = pkgs.callPackage ./plugins.nix { inherit inputs; };
  };

  # all ftplugin configs:
  xdg.configFile."nvim/ftplugin/" = {
    source = ./ftplugin;
    recursive = true;
  };
}

