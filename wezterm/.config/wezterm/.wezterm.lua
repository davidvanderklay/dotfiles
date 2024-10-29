-- Pull in the wezterm API
local wezterm = require("wezterm")
local session_manager = require("wezterm-session-manager/session-manager")
-- This will hold the configuration.
--
local config = wezterm.config_builder()

wezterm.on("save_session", function(window)
	session_manager.save_state(window)
end)
wezterm.on("load_session", function(window)
	session_manager.load_state(window)
end)
wezterm.on("restore_session", function(window)
	session_manager.restore_state(window)
end)

config.keys = {
	{ key = "S", mods = "LEADER", action = wezterm.action({ EmitEvent = "save_session" }) },
	{ key = "L", mods = "LEADER", action = wezterm.action({ EmitEvent = "load_session" }) },
	{ key = "R", mods = "LEADER", action = wezterm.action({ EmitEvent = "restore_session" }) },
}
-- This is where you actually apply your config choices
config.color_scheme = "Gruvbox Material (Gogh)"
config.font = wezterm.font({
	family = "Iosevka Nerd Font Mono",
	stretch = "Expanded",
	weight = "Regular",
})
config.font_size = 13
-- config.frontend = "WebGpu"

if os.getenv("XDG_CURRENT_DESKTOP") == "Hyprland" then
	config.enable_wayland = true
else
	config.enable_wayland = true
end

-- For example, changing the color scheme:

-- and finally, return the configuration to wezterm
return config
