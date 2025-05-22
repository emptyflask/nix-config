local alpha = require("alpha")

local dashboard = function()
  local theme = require("alpha.themes.dashboard")
  local logo = [[
                                             
      ████ ██████           █████      ██
     ███████████             █████ 
     █████████ ███████████████████ ███   ███████████
    █████████  ███    █████████████ █████ ██████████████
   █████████ ██████████ █████████ █████ █████ ████ █████
 ███████████ ███    ███ █████████ █████ █████ ████ █████
██████  █████████████████████ ████ █████ █████ ████ ██████
]]
  theme.section.header.val = vim.split(logo, "\n")
  theme.section.header.opts.hl = "AlphaHeader"
  theme.config.layout[1].val = 6
  theme.section.buttons.val = {
    theme.button("e", " " .. " New file", ":ene<CR>"),
    theme.button("f", " " .. " Find file", ":FzfLua files<CR>"),
    theme.button("r", " " .. " Recent files", ":FzfLua oldfiles<CR>"),
    theme.button("g", " " .. " Find text", ":FzfLua live_grep_native<CR>"),
    theme.button("q", " " .. " Quit", ":qa<CR>"),
  }
  return theme
end

alpha.setup(require 'alpha.themes.startify'.config)

alpha.setup(dashboard().config)
