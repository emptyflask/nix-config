-- Hide mode since lightline shows it
vim.opt.showmode = false

-- Lightline helper functions
local function lightline_readonly()
  return vim.bo.readonly and '' or ''
end

local function lightline_fugitive()
  if vim.fn.exists('*FugitiveHead') == 1 then
    local branch = vim.fn.FugitiveHead()
    return branch ~= '' and ' ' .. branch or ''
  end
  return ''
end

local function coc_current_function()
  return vim.b.coc_current_function or ''
end

-- Lightline configuration
vim.g.lightline = {
  active = {
    left = {
      { 'mode',      'paste' },
      { 'gitbranch', 'readonly', 'filename', 'modified', 'cocstatus', 'currentfunction' }
    }
  },
  colorscheme = 'jellybeans',
  component = {
    lineinfo = ' %3l:%-2v'
  },
  component_function = {
    readonly = 'v:lua.require("statusline").lightline_readonly',
    gitbranch = 'v:lua.require("statusline").lightline_fugitive',
    cocstatus = 'coc#status',
    currentfunction = 'v:lua.require("statusline").coc_current_function'
  },
  separator = {
    left = '\u{e0b0}',
    right = '\u{e0b2}'
  },
  subseparator = {
    left = '\u{e0b1}',
    right = '\u{e0b3}'
  }
}

-- Export functions for use in lightline
return {
  lightline_readonly = lightline_readonly,
  lightline_fugitive = lightline_fugitive,
  coc_current_function = coc_current_function
}
