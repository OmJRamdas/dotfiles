local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- appearance
config.color_scheme = "Gruvbox dark, hard (base16)"
config.font = wezterm.font("JetBrains Mono")
config.font_size = 13.0

-- window
config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }
config.window_background_opacity = 1.0

-- keybinds
-- config.keys = {}

return config
