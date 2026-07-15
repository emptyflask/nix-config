setlocal foldmethod=manual
setlocal foldexpr=
setlocal syntax=off
setlocal nowrap
lua pcall(vim.treesitter.stop, vim.api.nvim_get_current_buf())
