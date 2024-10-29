-- Pull in the wezterm API
local wezterm = require("wezterm")
-- This will hold the configuration.
--
local config = wezterm.config_builder()

-- config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
-- This is where you actually apply your config choices
config.color_scheme = "Gruvbox Material (Gogh)"
config.font = wezterm.font({
	family = "Iosevka Nerd Font Mono",
	stretch = "Expanded",
	weight = "Regular",
})
config.font_size = 13

-- and finally, return the configuration to wezterm
return config
