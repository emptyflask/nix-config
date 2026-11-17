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

-- zmx helpers (mirror kitty's zmx_switch.py). zmx's own ctrl+\ detach key is
-- disabled (ZMX_NO_DETACH_KEY in zshrc), so detaching runs `zmx detach` out
-- of band, which works no matter what program is running inside the session.

-- Session name from `zmx attach [--labels kv] <name> [cmd...]`
local function zmx_attached(pane)
  local info = pane:get_foreground_process_info()
  if not info or not info.argv then return nil end
  local argv = info.argv
  if (info.executable or ""):match("([^/]+)$") ~= "zmx" then return nil end
  if argv[2] ~= "attach" and argv[2] ~= "a" then return nil end
  local i = 3
  while argv[i] and argv[i]:sub(1, 2) == "--" do
    i = i + (argv[i] == "--labels" and 2 or 1)
  end
  if not argv[i] then return nil end
  return info.executable, argv[i]
end

local function zmx_detach(exe, session)
  wezterm.background_child_process { "env", "ZMX_SESSION=" .. session, exe, "detach" }
end

-- ctrl+shift+\: detach the session in this pane
local zmx_detach_action = wezterm.action_callback(function(_, pane)
  local exe, session = zmx_attached(pane)
  if session then zmx_detach(exe, session) end
end)

-- ctrl+shift+b: inside zmx, detach (zsm, if it attached the session, reopens
-- its list); at a bare zsh prompt, run zsm; otherwise do nothing
local zmx_switch = wezterm.action_callback(function(_, pane)
  local exe, session = zmx_attached(pane)
  if session then
    zmx_detach(exe, session)
  elseif (pane:get_foreground_process_name() or ""):match("([^/]+)$") == "zsh" then
    pane:send_text("\x15zsm\r")
  end
end)

-- Keybindings (matching kitty)
-- ctrl+shift+n:     new window          (kitty: new_os_window_with_cwd)
-- ctrl+shift+t:     new tab with cwd    (kitty: new_tab_with_cwd)
-- ctrl+shift+enter: split with cwd      (kitty: new_window)
-- ctrl+shift+\:     zmx detach
-- ctrl+shift+b:     zmx session switcher
-- ctrl+shift+y: detach tab has no WezTerm equivalent; omitted
config.keys = {
  { key = "n",          mods = "CTRL|SHIFT", action = wezterm.action.SpawnCommandInNewWindow {}, },
  { key = "t",          mods = "CTRL|SHIFT", action = wezterm.action.SpawnTab "CurrentPaneDomain", },
  { key = "Enter",      mods = "CTRL|SHIFT", action = wezterm.action.SplitPane { direction = "Right", command = { domain = "CurrentPaneDomain" } }, },
  { key = "\\",         mods = "CTRL|SHIFT", action = zmx_detach_action },
  { key = "|",          mods = "CTRL|SHIFT", action = zmx_detach_action },
  { key = "b",          mods = "CTRL|SHIFT", action = zmx_switch },
  { key = "B",          mods = "CTRL|SHIFT", action = zmx_switch },
  { key = "LeftArrow",  mods = "CTRL|SHIFT", action = wezterm.action.ActivateTabRelative(-1) },
  { key = "RightArrow", mods = "CTRL|SHIFT", action = wezterm.action.ActivateTabRelative(1) },
}

return config
