local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- ********** Theme/UI **********
config.color_scheme = "Ashes (base16)"
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
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.show_tab_index_in_tab_bar = false
config.switch_to_last_active_tab_when_closing_tab = true

-- タブバーの透過とフォント設定
config.window_frame = {
	inactive_titlebar_bg = "none",
	active_titlebar_bg = "none",
	font = wezterm.font("FantasqueSansM Nerd Font Mono"),
	font_size = 14,
}

-- テーマから色を取得
local scheme = wezterm.color.get_builtin_schemes()[config.color_scheme]

-- タブバーを背景色に合わせる
config.window_background_gradient = {
	colors = { scheme.background },
}

-- タブの追加ボタンを非表示
config.show_new_tab_button_in_tab_bar = false

-- タブ同士の境界線を非表示
config.colors = {
	tab_bar = {
		inactive_tab_edge = "none",
	},

	-- Quick Select Mode のハイライト色
	quick_select_label_bg = { Color = scheme.ansi[2] }, -- red
	quick_select_label_fg = { Color = scheme.background },
	quick_select_match_bg = { Color = scheme.ansi[5] }, -- blue
	quick_select_match_fg = { Color = scheme.foreground },
}

-- タブの形をカスタマイズ（矢印型）
local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local background = scheme.brights[1] -- bright black (gray)
	local foreground = scheme.foreground
	local edge_background = "none"
	if tab.is_active then
		background = scheme.ansi[4] -- yellow
		foreground = scheme.background
	end
	local edge_foreground = background
	-- タブタイトルから "Copy mode: " を除去
	local pane_title = tab.active_pane.title:gsub("^Copy mode: ", "")
	local title = "   " .. wezterm.truncate_right(pane_title, max_width - 1) .. "   "
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

-- ステータスバーに現在のモードを表示
wezterm.on("update-status", function(window, pane)
	local mode = window:active_key_table()
	local mode_text = "NORMAL"
	local mode_color = scheme.ansi[3] -- green

	if mode == "copy_mode" then
		mode_text = "COPY"
		mode_color = scheme.ansi[6] -- magenta
	elseif mode == "search_mode" then
		mode_text = "SEARCH"
		mode_color = scheme.ansi[7] -- cyan
	end

	window:set_right_status(wezterm.format({
		{ Foreground = { Color = scheme.background } },
		{ Background = { Color = mode_color } },
		{ Text = " " .. mode_text .. " " },
	}))
end)

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

	-- Copy Mode (Ctrl+Shift+c)
	{
		key = "phys:c",
		mods = "CTRL|SHIFT",
		action = act.ActivateCopyMode,
	},

	-- Search Mode (Ctrl+Shift+f)
	{
		key = "phys:f",
		mods = "CTRL|SHIFT",
		action = act.Search({ CaseInSensitiveString = "" }),
	},

	-- Quick Select Mode (Ctrl+Shift+/)
	{
		key = "phys:Slash",
		mods = "CTRL|SHIFT",
		action = act.QuickSelect,
	},
}

-- キーテーブル（デフォルトを維持しつつカスタマイズ）
local copy_mode = nil
local search_mode = nil

if wezterm.gui then
	copy_mode = wezterm.gui.default_key_tables().copy_mode
	search_mode = wezterm.gui.default_key_tables().search_mode

	-- Copy Mode: y でコピーして選択解除（Copy Modeに残る）
	table.insert(copy_mode, {
		key = "y",
		mods = "NONE",
		action = act.Multiple({
			act.CopyTo("ClipboardAndPrimarySelection"),
			act.ClearSelection,
			act.CopyMode("ClearSelectionMode"),
		}),
	})

	-- Copy Mode: Esc で選択がある場合は解除、ない場合はCopy Mode終了
	table.insert(copy_mode, {
		key = "Escape",
		mods = "NONE",
		action = wezterm.action_callback(function(window, pane)
			local selection = window:get_selection_text_for_pane(pane)
			if selection and #selection > 0 then
				window:perform_action(act.ClearSelection, pane)
				window:perform_action(act.CopyMode("ClearSelectionMode"), pane)
			else
				window:perform_action(act.CopyMode("Close"), pane)
			end
		end),
	})

	-- Copy Mode: n で次の検索結果、N で前の検索結果
	table.insert(copy_mode, {
		key = "n",
		mods = "NONE",
		action = act.CopyMode("NextMatch"),
	})
	table.insert(copy_mode, {
		key = "n",
		mods = "SHIFT",
		action = act.CopyMode("PriorMatch"),
	})

	-- Search Mode: Enter で検索確定してCopy Modeへ
	table.insert(search_mode, {
		key = "Enter",
		mods = "NONE",
		action = act.CopyMode("AcceptPattern"),
	})

	-- Search Mode: Esc で検索キャンセル
	table.insert(search_mode, {
		key = "Escape",
		mods = "NONE",
		action = act.CopyMode("Close"),
	})

	-- Search Mode: 上矢印で検索パターンをクリア
	table.insert(search_mode, {
		key = "UpArrow",
		mods = "NONE",
		action = act.CopyMode("ClearPattern"),
	})
end

config.key_tables = {
	copy_mode = copy_mode,
	search_mode = search_mode,
}

return config
