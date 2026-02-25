local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- ********** Theme/UI **********
config.color_scheme = "Ashes (base16)"

-- Tab bar plugin (must be after color_scheme)
local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")
bar.apply_to_config(config, {
	position = "top",
})

-- Override tab bar colors to be opaque (bar.wezterm defaults to "transparent")
config.colors.tab_bar.background = "#393F45"
config.colors.tab_bar.active_tab.bg_color = "#393F45"
config.colors.tab_bar.inactive_tab.bg_color = "#393F45"
config.colors.tab_bar.new_tab.bg_color = "#393F45"

config.window_background_opacity = 0.85
config.macos_window_background_blur = 20

-- Ghostty "macos-titlebar-style = transparent" equivalent
-- RESIZE only = no title bar, retains resize ability
config.window_decorations = "RESIZE"

config.use_ime = true

-- ********** Padding **********
config.window_padding = {
	left = 20,
	right = 20,
	top = 5,
	bottom = 5,
}

-- ********** Font **********
config.font = wezterm.font_with_fallback({
	{
		family = "FantasqueSansM Nerd Font Mono",
		harfbuzz_features = { "calt=0", "dlig=0", "liga=0" },
	},
	{ family = "Hiragino Kaku Gothic ProN" },
})
config.font_size = 16

-- ********** Tab bar **********
-- use_fancy_tab_bar / tab_max_width are managed by bar.wezterm
config.hide_tab_bar_if_only_one_tab = false
config.show_tab_index_in_tab_bar = false
config.switch_to_last_active_tab_when_closing_tab = true

-- ********** Keybindings **********
config.keys = {
	-- Disable conflicting defaults
	{ key = "L", mods = "CTRL|SHIFT", action = act.DisableDefaultAssignment },

	-- Split pane (Ctrl+Shift+' : right, Ctrl+Shift+; : down)
	{
		key = "phys:Quote",
		mods = "CTRL|SHIFT",
		action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "phys:Semicolon",
		mods = "CTRL|SHIFT",
		action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
	},

	-- Move pane (Ctrl+Shift+h/j/k/l)
	{
		key = "phys:h",
		mods = "CTRL|SHIFT",
		action = act.ActivatePaneDirection("Left"),
	},
	{
		key = "phys:j",
		mods = "CTRL|SHIFT",
		action = act.ActivatePaneDirection("Down"),
	},
	{
		key = "phys:k",
		mods = "CTRL|SHIFT",
		action = act.ActivatePaneDirection("Up"),
	},
	{
		key = "phys:l",
		mods = "CTRL|SHIFT",
		action = act.ActivatePaneDirection("Right"),
	},

	-- Resize pane (Ctrl+Shift+Cmd+h/j/k/l, 10 cells)
	{
		key = "phys:h",
		mods = "CTRL|SHIFT|SUPER",
		action = act.AdjustPaneSize({ "Left", 10 }),
	},
	{
		key = "phys:j",
		mods = "CTRL|SHIFT|CMD",
		action = act.AdjustPaneSize({ "Down", 10 }),
	},
	{
		key = "phys:k",
		mods = "CTRL|SHIFT|CMD",
		action = act.AdjustPaneSize({ "Up", 10 }),
	},
	{
		key = "phys:l",
		mods = "CTRL|SHIFT|CMD",
		action = act.AdjustPaneSize({ "Right", 10 }),
	},

	-- Scroll pane (Ctrl+Shift+u : page down, Ctrl+Shift+i : page up)
	{
		key = "phys:u",
		mods = "CTRL|SHIFT",
		action = act.ScrollByPage(1),
	},
	{
		key = "phys:i",
		mods = "CTRL|SHIFT",
		action = act.ScrollByPage(-1),
	},

	-- Create tab (Ctrl+Shift+t)
	{
		key = "phys:t",
		mods = "CTRL|SHIFT",
		action = act.SpawnTab("CurrentPaneDomain"),
	},

	-- Move tab (Ctrl+Shift+, : previous, Ctrl+Shift+. : next)
	{
		key = "phys:Comma",
		mods = "CTRL|SHIFT",
		action = act.ActivateTabRelative(-1),
	},
	{
		key = "phys:Period",
		mods = "CTRL|SHIFT",
		action = act.ActivateTabRelative(1),
	},

	-- Create window (Ctrl+Shift+w)
	{
		key = "phys:w",
		mods = "CTRL|SHIFT",
		action = act.SpawnWindow,
	},
}

return config
