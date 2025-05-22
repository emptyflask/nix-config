-- Basic mappings
vim.keymap.set('n', '<Enter>', 'o<ESC>', { silent = true })
vim.keymap.set('n', '<S-Enter>', 'O<ESC>', { silent = true })

-- FZF Lua mappings
vim.keymap.set('n', '<leader>a', ':FzfLua grep_project<CR>', { silent = true })
vim.keymap.set('n', '<leader>f', ':FzfLua files<CR>', { silent = true })
vim.keymap.set('n', '<leader>gf', function()
  require('fzf-lua').files({ cwd = vim.fn.expand('%:h') })
end, { silent = true })
vim.keymap.set('n', '<leader>d', ':FzfLua git_status<CR>', { silent = true })
vim.keymap.set('n', '<leader>b', ':FzfLua buffers<CR>', { silent = true })
vim.keymap.set('n', '<leader>/', ':FzfLua grep_curbuf<CR>', { silent = true })

-- Word completion (Note: This requires additional setup for fzf integration)
-- vim.keymap.set('i', '<c-x><c-k>', function()
--     -- Implementation needed for fzf dictionary completion
-- end, { expr = true })

-- Diagnostic float
vim.keymap.set('n', 'g?', vim.diagnostic.open_float, { silent = true })

-- Directory navigation
vim.keymap.set('c', '%%', function()
  return vim.fn.expand('%:h') .. '/'
end, { expr = true })
vim.keymap.set('n', '<leader>e', ':edit <C-R>=expand("%:h")."/"<CR>')

-- Escape mapping
vim.keymap.set('i', 'kj', '<ESC>')

-- Quickfix navigation
vim.keymap.set('n', '<c-b>', ':cprevious<CR>')
vim.keymap.set('n', '<c-n>', ':cnext<CR>')

-- Clear search highlighting
vim.keymap.set('n', '<leader><esc>', ':noh<CR>', { silent = true })
vim.keymap.set('n', '<c-_>', ':noh<CR>', { silent = true })
vim.keymap.set('n', '<c-/>', ':noh<CR>', { silent = true })

-- Very magic search
vim.keymap.set('n', '//', '/\\v')

-- Cursor movement
vim.keymap.set('n', '<up>', 'gk')
vim.keymap.set('v', '<up>', 'gk')
vim.keymap.set('i', '<up>', '<C-o>gk')
vim.keymap.set('n', '<down>', 'gj')
vim.keymap.set('v', '<down>', 'gj')
vim.keymap.set('i', '<down>', '<C-o>gj')

if not vim.g.vimpager then
  vim.keymap.set('n', 'j', 'gj')
  vim.keymap.set('n', 'k', 'gk')
end

-- Cursor line/column toggles
vim.opt.cursorline = true
vim.keymap.set('n', '<leader>c', ':set cursorline!<CR>')
vim.keymap.set('n', '<leader>C', ':set cursorcolumn!<CR>')

-- Word navigation
vim.keymap.set('n', 'E', 'ge')

-- Buffer switching
vim.keymap.set('n', '<leader><leader>', '<c-^>')

-- Macro execution
vim.keymap.set('n', 'Q', '@q')

-- Sudo write command
vim.api.nvim_create_user_command('W', 'w !sudo tee % > /dev/null', {})

-- Yank to end of line
vim.keymap.set('n', 'Y', 'y$')

-- Surround mappings
vim.keymap.set('n', '<leader>#', 'ciw#{<C-R>"}<ESC>')
vim.keymap.set('v', '<leader>#', 'c#{<C-R>"}<ESC>')

-- Quote surrounds
vim.keymap.set('n', '<leader>"', 'saiw"')
vim.keymap.set('v', '<leader>"', 'sa"')
vim.keymap.set('n', "<leader>'", "saiw'")
vim.keymap.set('v', "<leader>'", "sa'")

-- Bracket surrounds
vim.keymap.set('n', '<leader>(', 'saiw(')
vim.keymap.set('n', '<leader>)', 'saiw)')
vim.keymap.set('v', '<leader>(', 'c( <C-R>" )<ESC>')
vim.keymap.set('v', '<leader>)', 'c(<C-R>")<ESC>')

-- Square bracket surrounds
vim.keymap.set('n', '<leader>]', 'saiw]')
vim.keymap.set('n', '<leader>[', 'saiw[')
vim.keymap.set('v', '<leader>[', 'c[ <C-R>" ]<ESC>')
vim.keymap.set('v', '<leader>]', 'c[<C-R>"]<ESC>')

-- Brace surrounds
vim.keymap.set('n', '<leader>}', 'saiw}')
vim.keymap.set('n', '<leader>{', 'saiw{')
vim.keymap.set('v', '<leader>}', 'c{ <C-R>" }<ESC>')
vim.keymap.set('v', '<leader>{', 'c{<C-R>"}<ESC>')

-- Window navigation
vim.keymap.set('n', '<c-j>', '<c-w>j')
vim.keymap.set('n', '<c-k>', '<c-w>k')
vim.keymap.set('n', '<c-h>', '<c-w>h')
vim.keymap.set('n', '<c-l>', '<c-w>l')

-- Split creation
vim.keymap.set('n', '<leader>v', ':vsp<CR>')
vim.keymap.set('n', '<leader>h', ':split<CR>')

-- Window sizing
vim.keymap.set('n', '<Leader>=', '<C-w>=')
vim.keymap.set('n', '<leader>\\', '<C-w>|')

-- Manual window resize
vim.keymap.set('n', '<M-Left>', ':vertical resize -4<CR>', { silent = true })
vim.keymap.set('n', '<M-Right>', ':vertical resize +4<CR>', { silent = true })
vim.keymap.set('n', '<M-Up>', ':resize +4<CR>', { silent = true })
vim.keymap.set('n', '<M-Down>', ':resize -4<CR>', { silent = true })

-- Undo/Redo
vim.keymap.set('n', 'U', ':redo<CR>')
vim.keymap.set('n', '<F2>', ':UndotreeToggle<CR>')

-- Preserve undo in insert mode
vim.keymap.set('i', '<c-u>', '<c-g>u<c-u>')
vim.keymap.set('i', '<c-w>', '<c-g>u<c-w>')

-- Tab navigation
vim.keymap.set('n', '<M-[>', ':tabp<CR>')
vim.keymap.set('n', '<M-]>', ':tabn<CR>')
vim.keymap.set('n', '<leader>t', ':tabe<CR>')
vim.keymap.set('n', '<M-t>', ':tabe<CR>')
vim.keymap.set('n', '<M-q>', ':tabclose<CR>')

-- Buffer deletion
vim.keymap.set('n', '<leader><bs>', ':bd!<CR>')

-- Special function keys
vim.keymap.set('n', '<F3>', ':CopilotChatToggle<CR>')
vim.keymap.set('n', '<F4>', ':Errors<CR>')
vim.keymap.set('n', '<F8>', ':TagbarOpenAutoClose<CR>')

-- Commentary mappings
vim.keymap.set('x', '\\\\', '<Plug>Commentary')
vim.keymap.set('n', '\\\\', '<Plug>Commentary')
vim.keymap.set('o', '\\\\', '<Plug>Commentary')
vim.keymap.set('n', '\\\\\\', '<Plug>CommentaryLine')

-- File browser
vim.keymap.set('n', '<c-d>', ':NvimTreeToggle<CR>')
vim.keymap.set('n', '<c-e>', ':NvimTreeFindFile<CR>')

-- Syntax inspection
vim.keymap.set('n', '<F10>', function()
  local stack = vim.fn.synstack(vim.fn.line('.'), vim.fn.col('.'))
  local names = {}
  for i, v in ipairs(stack) do
    table.insert(names, vim.fn.synIDattr(v, 'name'))
  end
  print(table.concat(vim.fn.reverse(names), ' '))
end)
