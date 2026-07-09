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
      # vim-gutentags
      Rename
      ale
      fastfold
      fzf-vim
      fzf-wrapper
      gruvbox-community
      hlint-refactor-vim
      lightline-vim
      neco-ghc
      neosnippet-snippets
      neosnippet-vim
      tabular
      tagbar
      tlib_vim
      undotree
      vim-commentary
      vim-dispatch
      vim-fugitive
      vim-gitgutter
      vim-grepper
      vim-hindent
      vim-polyglot
      vim-repeat
      vim-sensible
      vim-snippets
      vim-speeddating
      vim-startify
      vim-surround
      vim-test
      vim-unimpaired
      vimproc-vim
      vimwiki
    ];
  };
}
