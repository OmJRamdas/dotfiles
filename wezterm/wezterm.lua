local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- appearance
config.color_scheme = "rose-pine"
config.font = wezterm.font("Cascadia Code", { weight = "Regular" })
config.font_size = 14.0
config.line_height = 1.2
config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }
config.freetype_load_target = "Light"
config.freetype_render_target = "HorizontalLcd"
config.allow_square_glyphs_to_overflow_width = "Never"
config.custom_block_glyphs = false
config.unicode_version = 9

-- override blue with warm orange
config.colors = {
  ansi = {
    "#191724", -- black
    "#eb6f92", -- red
    "#31748f", -- green
    "#f6c177", -- yellow
    "#ea9d34", -- orange (was blue)
    "#c4a7e7", -- magenta
    "#ebbcba", -- cyan
    "#e0def4", -- white
  },
  brights = {
    "#26233a", -- bright black
    "#eb6f92", -- bright red
    "#31748f", -- bright green
    "#f6c177", -- bright yellow
    "#f4b460", -- bright orange (was bright blue)
    "#c4a7e7", -- bright magenta
    "#ebbcba", -- bright cyan
    "#e0def4", -- bright white
  },
  selection_fg = "#191724",
  selection_bg = "#ea9d34",
}

-- window
config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }
config.window_background_opacity = 0.9




-- keybinds
config.keys = {
  { key = "c",          mods = "CTRL|SHIFT", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
  { key = "{",          mods = "CTRL|SHIFT", action = wezterm.action.ActivateTabRelative(-1) },
  { key = "}",          mods = "CTRL|SHIFT", action = wezterm.action.ActivateTabRelative(1) },
  { key = "UpArrow",    mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Up") },
  { key = "DownArrow",  mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Down") },
  { key = "LeftArrow",  mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Left") },
  { key = "RightArrow", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Right") },
}

return config
