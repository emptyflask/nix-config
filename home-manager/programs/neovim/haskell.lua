-- Haskell syntax highlighting options
vim.g.haskell_enable_quantification = 1   -- enable highlighting of `forall`
vim.g.haskell_enable_recursivedo = 1      -- enable highlighting of `mdo` and `rec`
vim.g.haskell_enable_arrowsyntax = 1      -- enable highlighting of `proc`
vim.g.haskell_enable_pattern_synonyms = 1 -- enable highlighting of `pattern`
vim.g.haskell_enable_typeroles = 1        -- enable highlighting of type roles
vim.g.haskell_enable_static_pointers = 1  -- enable highlighting of `static`
vim.g.haskell_backpack = 1                -- enable highlighting of backpack keywords
-- vim.g.haskell_classic_highlighting = 1   -- classic highlighting (commented out)

-- HLint refactor settings
vim.g.hlintRefactor = {
  disableDefaultKeybindings = 1
}
