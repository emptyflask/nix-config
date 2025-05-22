-- Enable true color support
vim.opt.termguicolors = true
vim.opt.background = 'dark'
vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1

-- Basic settings
vim.opt.compatible = false
vim.opt.shell = vim.env.SHELL

-- Mouse support
vim.opt.mouse = 'a'

-- Buffer handling
vim.opt.hidden = true

-- Command and search history
vim.opt.history = 1000

-- File completion
vim.opt.wildmenu = true
vim.opt.wildmode = 'longest,list'
vim.opt.wildignore = {
  '*.gif', '*.jpg', '*.png',
  '*.o', '*.obj',
  '.git', '.svn',
  'tmp'
}

-- Folding
vim.opt.foldlevel = 10
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'

-- Leader and clipboard
vim.g.mapleader = ','
vim.opt.clipboard:append('unnamedplus')

-- Indentation
vim.opt.autoindent = true  -- automatically set indent of new line
vim.opt.smartindent = true -- smart autoindenting for C programs

-- Window handling
vim.opt.equalalways = true -- make windows equal size
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Search settings
vim.opt.hlsearch = true   -- highlight search results
vim.opt.incsearch = true  -- incremental search
vim.opt.ignorecase = true -- ignore case when searching
vim.opt.smartcase = true  -- ignore case if search pattern is all lowercase

-- Live command feedback
vim.opt.inccommand = 'nosplit'

-- Wrapping and scrolling
vim.opt.wrap = false
vim.opt.linebreak = true -- wrap at word
vim.opt.scrolloff = 4
vim.opt.sidescrolloff = 4

-- List characters
vim.opt.listchars = {
  trail = '·',
  tab = '‣ ',
  extends = '',
  precedes = '',
  nbsp = '␣'
}

vim.opt.list = true

-- Tabs and spaces
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.shiftround = true
vim.opt.tabstop = 2
vim.opt.expandtab = true
vim.opt.smarttab = true

-- Session options
vim.opt.sessionoptions = {
  'blank',
  'buffers',
  'curdir',
  'folds',
  'help',
  'resize',
  'tabpages',
  'winsize'
}

-- Miscellaneous settings
vim.opt.backspace = 'indent,eol,start'
vim.opt.number = true
vim.opt.matchpairs:append('<:>')
vim.opt.autoread = true

-- Large file handling
vim.g.LargeFile = 64
vim.opt.synmaxcol = 512
vim.opt.lazyredraw = true

-- Enable filetype detection and plugins
vim.cmd('filetype plugin indent on')

-- Completion options
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

-- Optional: Highlight yanked text (requires Neovim 0.5+)
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 1000 })
  end,
})
