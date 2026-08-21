local wezterm = require("wezterm")
local act = wezterm.action
local notify = wezterm.plugin.require("https://github.com/Tiger-0512/wezterm-notify")
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
-- テキスト表示用と絵文字用は独立しているため、同じフォントを2回指定してフォールバックさせる必要がある
-- ref: https://zenn.dev/paiza/articles/9ca689a0365b05
config.font = wezterm.font_with_fallback({
	{
		family = "FantasqueSansM Nerd Font Mono",
		harfbuzz_features = { "calt=0", "dlig=0", "liga=0" },
	},
	{ family = "FantasqueSansM Nerd Font Mono", assume_emoji_presentation = true },
	{ family = "Hiragino Kaku Gothic ProN" },
})
config.font_size = 16

-- ********** Tab bar **********
-- tab は Herdr で管理するため、WezTerm 側の tab bar は表示しない。
-- tab bar が無効な間は左右の status 行も描画されないため、
-- format-tab-title / update-status による装飾とモード表示は行わない。
config.enable_tab_bar = false

-- テーマから色を取得
local scheme = wezterm.color.get_builtin_schemes()[config.color_scheme]

config.colors = {
	-- Quick Select Mode のハイライト色
	quick_select_label_bg = { Color = scheme.ansi[2] }, -- red
	quick_select_label_fg = { Color = scheme.background },
	quick_select_match_bg = { Color = scheme.ansi[5] }, -- blue
	quick_select_match_fg = { Color = scheme.foreground },
}

-- 未読通知の tab 表示は tab bar と一緒に廃止したため、
-- active tab の通知状態だけを継続してクリアする。
wezterm.on("update-status", function(window, _pane)
	notify.clear_active_tab(window)
end)

-- ********** Keybindings **********
config.keys = {
	-- Disable conflicting defaults
	{ key = "L", mods = "CTRL|SHIFT", action = act.DisableDefaultAssignment },
	{ key = "N", mods = "CTRL|SHIFT", action = act.DisableDefaultAssignment },
	-- tab は Herdr で管理する。tab bar が無効で新しい tab を視認できないため、
	-- WezTerm 側の tab 生成は割り当てず既定の割り当ても無効化する。
	{ key = "T", mods = "CTRL|SHIFT", action = act.DisableDefaultAssignment },
	{ key = "t", mods = "SUPER", action = act.DisableDefaultAssignment },

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

	-- Send Herdr shortcuts with CSI-u so modifiers survive terminal input.
	{
		key = "phys:w",
		mods = "CTRL",
		action = act.SendString("\x1b[119;5u"),
	},
	{
		key = "mapped:w",
		mods = "CTRL",
		action = act.SendString("\x1b[119;5u"),
	},
	{
		key = "phys:Comma",
		mods = "CTRL",
		action = act.SendString("\x1b[44;5u"),
	},
	{
		key = "mapped:,",
		mods = "CTRL",
		action = act.SendString("\x1b[44;5u"),
	},
	{
		key = "phys:Period",
		mods = "CTRL",
		action = act.SendString("\x1b[46;5u"),
	},
	{
		key = "mapped:.",
		mods = "CTRL",
		action = act.SendString("\x1b[46;5u"),
	},
	{
		key = "Escape",
		mods = "CTRL",
		action = act.SendString("\x1b[27;5u"),
	},

	-- Create window (Ctrl+Shift+w)
	{
		key = "phys:w",
		mods = "CTRL|SHIFT",
		action = act.SpawnWindow,
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

notify.apply_to_config(config)

return config
