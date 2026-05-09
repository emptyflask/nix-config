{pkgs, ...}:
with pkgs; {
  programs.vim = {
    enable = true;

    extraConfig =
      (builtins.readFile ./vimrc)
      + ''
        syntax on
        filetype plugin indent on

        let g:haskell_enable_quantification = 1   " to enable highlighting of `forall`
        let g:haskell_enable_recursivedo = 1      " to enable highlighting of `mdo` and `rec`
        let g:haskell_enable_arrowsyntax = 1      " to enable highlighting of `proc`
        let g:haskell_enable_pattern_synonyms = 1 " to enable highlighting of `pattern`
        let g:haskell_enable_typeroles = 1        " to enable highlighting of type roles
        let g:haskell_enable_static_pointers = 1  " to enable highlighting of `static`
        let g:haskell_backpack = 1                " to enable highlighting of backpack keywords
      '';

    plugins = with pkgs.vimPlugins; [
      Rename
      tabular
      tagbar
      ale
      fastfold
      vim-fugitive
      fzf-vim
      fzf-wrapper
      vim-gitgutter
      gruvbox-community
      hlint-refactor-vim
      lightline-vim
      neco-ghc
      neosnippet-vim
      neosnippet-snippets
      vim-repeat
      vim-sensible
      vim-surround
      tlib_vim
      undotree
      vim-commentary
      vim-dispatch
      vim-grepper
      # vim-gutentags
      vim-hindent
      vim-polyglot
      vim-snippets
      vim-speeddating
      vim-startify
      vim-test
      vim-unimpaired
      vimproc-vim
      vimwiki
    ];
  };
}
