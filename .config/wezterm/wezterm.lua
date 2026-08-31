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
	-- Send Herdr shortcuts with CSI-u so modifiers survive terminal input.
	{
		key = "phys:m",
		mods = "CTRL",
		action = act.SendString("\x1b[109;5u"),
	},
	{
		key = "mapped:m",
		mods = "CTRL",
		action = act.SendString("\x1b[109;5u"),
	},
	{
		key = "phys:Comma",
		mods = "CTRL",
		action = act.SendString("\x1b[44;5u"),
	},
	{
		key = "phys:Period",
		mods = "CTRL",
		action = act.SendString("\x1b[46;5u"),
	},
	{
		key = "phys:Slash",
		mods = "CTRL",
		action = act.SendString("\x1b[47;5u"),
	},
	{
		key = "Escape",
		mods = "CTRL",
		action = act.SendString("\x1b[27;5u"),
	},

	-- Tab creation/navigation and workspace navigation (Ctrl+Shift+t/h/j/k/l).
	-- ctrl+shift+<letter> has no legacy encoding distinct from ctrl+<letter>,
	-- so CSI-u is required for Herdr to see the shift modifier.
	{
		key = "phys:t",
		mods = "CTRL|SHIFT",
		action = act.SendString("\x1b[116;6u"),
	},
	{
		key = "phys:h",
		mods = "CTRL|SHIFT",
		action = act.SendString("\x1b[104;6u"),
	},
	{
		key = "phys:j",
		mods = "CTRL|SHIFT",
		action = act.SendString("\x1b[106;6u"),
	},
	{
		key = "phys:k",
		mods = "CTRL|SHIFT",
		action = act.SendString("\x1b[107;6u"),
	},
	{
		key = "phys:l",
		mods = "CTRL|SHIFT",
		action = act.SendString("\x1b[108;6u"),
	},

	-- Copy mode と pane resize mode。
	-- ctrl+shift+<letter> は legacy encoding で ctrl+<letter> と区別できないため
	-- CSI-u が必須。
	{
		key = "phys:y",
		mods = "CTRL|SHIFT",
		action = act.SendString("\x1b[121;6u"),
	},
	{
		key = "phys:r",
		mods = "CTRL|SHIFT",
		action = act.SendString("\x1b[114;6u"),
	},

	-- Ctrl+Shift+a / Ctrl+Shift+s の scroll は Hammerspoon 側で本物の
	-- ホイールイベントとして送る。

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

-- tab / pane / scroll / copy mode は Herdr が担うため、WezTerm 側では同等の操作を
-- 割り当てず、既定の割り当ても無効化して pane (= Herdr) へキーを通す。
-- WezTerm の既定は同じ操作を複数の表記で登録しているため、mapped の shift 形
-- (CTRL+"W" など) と物理キー形の双方を列挙する必要がある。
local disabled_default_keys = {
	-- SpawnWindow の既定を外し、通知ビューアの ctrl+shift+n を通す
	{ key = "N", mods = "CTRL|SHIFT" },

	-- 以前 WezTerm 側で pane 移動 / pane 分割 / scroll に割り当てていたキー。
	-- 割り当てを外すと ctrl+shift+h が HideApplication、ctrl+shift+k が
	-- ClearScrollback、ctrl+shift+u が CharSelect という無関係な既定に戻るため、
	-- Herdr のキーとして pane へ通すよう明示的に無効化する。
	-- h/j/k/l は上で phys 表記に CSI-u の SendString を割り当てているが、既定は
	-- mapped 表記 (CTRL+"H" と CTRL+"h") でも登録されているため両方を外しておく。
	{ key = "H", mods = "CTRL|SHIFT" },
	{ key = "h", mods = "CTRL|SHIFT" },
	{ key = "J", mods = "CTRL|SHIFT" },
	{ key = "j", mods = "CTRL|SHIFT" },
	{ key = "K", mods = "CTRL|SHIFT" },
	{ key = "k", mods = "CTRL|SHIFT" },
	{ key = "L", mods = "CTRL|SHIFT" },
	{ key = "l", mods = "CTRL|SHIFT" },
	{ key = "R", mods = "CTRL|SHIFT" },
	{ key = "r", mods = "CTRL|SHIFT" },
	{ key = "U", mods = "CTRL|SHIFT" },
	{ key = "u", mods = "CTRL|SHIFT" },
	{ key = "I", mods = "CTRL|SHIFT" },
	{ key = "i", mods = "CTRL|SHIFT" },
	{ key = '"', mods = "CTRL|SHIFT" },
	{ key = "'", mods = "CTRL|SHIFT" },
	{ key = ":", mods = "CTRL|SHIFT" },
	{ key = ";", mods = "CTRL|SHIFT" },

	-- tab 生成 (Herdr: ctrl+shift+t)
	{ key = "T", mods = "CTRL|SHIFT" },
	{ key = "t", mods = "SUPER" },

	-- tab 切り替え (Herdr: ctrl+shift+h / ctrl+shift+l)
	{ key = "Tab", mods = "CTRL" },
	{ key = "Tab", mods = "CTRL|SHIFT" },
	{ key = "PageUp", mods = "CTRL" },
	{ key = "PageDown", mods = "CTRL" },
	{ key = "[", mods = "SUPER|SHIFT" },
	{ key = "]", mods = "SUPER|SHIFT" },
	{ key = "{", mods = "SUPER" },
	{ key = "{", mods = "SUPER|SHIFT" },
	{ key = "}", mods = "SUPER" },
	{ key = "}", mods = "SUPER|SHIFT" },

	-- tab 順序の入れ替え (Herdr: move_tab_previous / move_tab_next)
	{ key = "PageUp", mods = "CTRL|SHIFT" },
	{ key = "PageDown", mods = "CTRL|SHIFT" },

	-- tab close (Herdr: prefix+shift+x)
	{ key = "W", mods = "CTRL" },
	{ key = "W", mods = "CTRL|SHIFT" },
	{ key = "w", mods = "CTRL|SHIFT" },
	{ key = "w", mods = "SUPER" },

	-- pane 分割 (Herdr: ctrl+; / ctrl+')
	{ key = '"', mods = "CTRL|ALT" },
	{ key = '"', mods = "CTRL|ALT|SHIFT" },
	{ key = "'", mods = "CTRL|ALT|SHIFT" },
	{ key = "%", mods = "CTRL|ALT" },
	{ key = "%", mods = "CTRL|ALT|SHIFT" },
	{ key = "5", mods = "CTRL|ALT|SHIFT" },

	-- pane focus (Herdr: ctrl+n/m/,/.)
	{ key = "LeftArrow", mods = "CTRL|SHIFT" },
	{ key = "RightArrow", mods = "CTRL|SHIFT" },
	{ key = "UpArrow", mods = "CTRL|SHIFT" },
	{ key = "DownArrow", mods = "CTRL|SHIFT" },

	-- pane resize (Herdr: ctrl+shift+r の resize mode)
	{ key = "LeftArrow", mods = "CTRL|ALT|SHIFT" },
	{ key = "RightArrow", mods = "CTRL|ALT|SHIFT" },
	{ key = "UpArrow", mods = "CTRL|ALT|SHIFT" },
	{ key = "DownArrow", mods = "CTRL|ALT|SHIFT" },

	-- pane zoom (Herdr: prefix+z)
	{ key = "Z", mods = "CTRL" },
	{ key = "Z", mods = "CTRL|SHIFT" },
	{ key = "z", mods = "CTRL|SHIFT" },

	-- scroll (Herdr: 修飾なしの pageup / pagedown で pane scrollback)
	{ key = "PageUp", mods = "SHIFT" },
	{ key = "PageDown", mods = "SHIFT" },

	-- copy mode (Herdr: ctrl+shift+y。WezTerm 側は ctrl+shift+f の検索から入る)
	{ key = "X", mods = "CTRL" },
	{ key = "X", mods = "CTRL|SHIFT" },
	{ key = "x", mods = "CTRL|SHIFT" },
}

-- tab の index 指定 (Herdr: prefix+1..9)。WezTerm は数字と shift 記号の両方に
-- ActivateTab を割り当てているため、どちらの表記も無効化する。
for i = 1, 9 do
	table.insert(disabled_default_keys, { key = tostring(i), mods = "CTRL|SHIFT" })
	table.insert(disabled_default_keys, { key = tostring(i), mods = "SUPER" })
end
for _, key in ipairs({ "!", "@", "#", "$", "%", "^", "&", "*", "(" }) do
	table.insert(disabled_default_keys, { key = key, mods = "CTRL" })
	table.insert(disabled_default_keys, { key = key, mods = "CTRL|SHIFT" })
end

for _, entry in ipairs(disabled_default_keys) do
	table.insert(config.keys, {
		key = entry.key,
		mods = entry.mods,
		action = act.DisableDefaultAssignment,
	})
end

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
