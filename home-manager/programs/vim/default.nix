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
      Tabular
      Tagbar
      ale
      fastfold
      fugitive
      fzf-vim
      fzfWrapper
      gitgutter
      gruvbox-community
      hlint-refactor
      lightline-vim
      neco-ghc
      neosnippet
      neosnippet-snippets
      repeat
      sensible
      surround
      tlib
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
      vimproc
      vimwiki
    ];
  };
}
