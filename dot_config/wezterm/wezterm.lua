local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local act = wezterm.action

config.keys = {
  {
    key = 'Enter',
    mods = 'SHIFT',
    action = act.SendString '\n',
  },
}

config.window_background_opacity = 0.8
config.text_background_opacity = 0.3
config.inactive_pane_hsb = {
  saturation = 0.8,
  brightness = 0.7,
}
config.font_size = 13
config.color_scheme = "Dracula"
config.enable_wayland = true
config.window_decorations = "NONE"

local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")
local sessions = wezterm.plugin.require("https://github.com/abidibo/wezterm-sessions")

sessions.apply_to_config(config)
bar.apply_to_config(config)

return config
