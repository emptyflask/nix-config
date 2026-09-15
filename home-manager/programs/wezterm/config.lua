local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Font
config.font = wezterm.font("Fira Code")
config.font_size = 11
config.font_rules = {
  {
    italic = false,
    intensity = "Bold",
    font = wezterm.font("Fira Code", { weight = "Bold" }),
  },
  {
    italic = true,
    intensity = "Normal",
    font = wezterm.font("JetBrains Mono", { italic = true }),
  },
  {
    italic = true,
    intensity = "Bold",
    font = wezterm.font("JetBrains Mono", { italic = true, weight = "Bold" }),
  },
}

-- Window
config.window_background_opacity = 0.9
config.window_decorations = "RESIZE"
-- config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }

-- Scrollback
config.scrollback_lines = 10000

-- Bell
config.audible_bell = "Disabled"

-- Tab bar
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.tab_max_width = 32

-- Powerline-style tabs, matching kitty's tab_bar_style = "powerline"
local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
local SOLID_RIGHT_ARROW = utf8.char(0xe0b0)

wezterm.on("format-tab-title", function(tab)
  local edge_background = "#272822" -- tab bar background
  local background = "#272822"
  local foreground = "#75715e"

  if tab.is_active then
    background = "#75715e"
    foreground = "#272822"
  end

  local edge_foreground = background
  local title = " " .. (tab.tab_index + 1) .. ": " .. tab.active_pane.title .. " "

  return {
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_LEFT_ARROW },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = title },
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_RIGHT_ARROW },
  }
end)

-- Match kitty: bold text keeps its literal ANSI color, just rendered in a bold
-- font weight, instead of WezTerm's default of swapping to the bright variant.
config.bold_brightens_ansi_colors = false

-- Colors (Gruvbox dark)
config.colors = {
  foreground    = "#ebdbb2",
  background    = "#0d1011",
  cursor_bg     = "#b5b3aa",
  cursor_border = "#b5b3aa",
  cursor_fg     = "#0d1011",
  selection_fg  = "#b5b3aa",
  selection_bg  = "#3c3836",
  ansi          = {
    "#1d2021", "#fb4934", "#b8bb26", "#fabd2f",
    "#83a598", "#d3869b", "#8ec07c", "#d5c4a1",
  },
  brights       = {
    "#665c54", "#fe8019", "#3c3836", "#504945",
    "#bdae93", "#ebdbb2", "#d65d0e", "#fbf1c7",
  },
  tab_bar       = {
    background = "#272822",
    active_tab = {
      bg_color = "#75715e",
      fg_color = "#272822",
    },
    inactive_tab = {
      bg_color = "#272822",
      fg_color = "#75715e",
    },
    inactive_tab_hover = {
      bg_color = "#272822",
      fg_color = "#75715e",
    },
    new_tab = {
      bg_color = "#272822",
      fg_color = "#75715e",
    },
    new_tab_hover = {
      bg_color = "#272822",
      fg_color = "#ebdbb2",
    },
  },
}

-- Keybindings (matching kitty)
-- ctrl+shift+n: new window with cwd (kitty: new_os_window_with_cwd)
-- ctrl+shift+t: new tab with cwd   (kitty: new_tab_with_cwd)
-- ctrl+shift+y: detach tab has no WezTerm equivalent; omitted
config.keys = {
  { key = "n",          mods = "CTRL|SHIFT", action = wezterm.action.SpawnCommandInNewWindow {}, },
  { key = "t",          mods = "CTRL|SHIFT", action = wezterm.action.SpawnTab "CurrentPaneDomain", },
  { key = "LeftArrow",  mods = "CTRL|SHIFT", action = wezterm.action.ActivateTabRelative(-1) },
  { key = "RightArrow", mods = "CTRL|SHIFT", action = wezterm.action.ActivateTabRelative(1) },
}

return config
