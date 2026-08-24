-- `hs` CLI (hs -c '...') から設定の reload や動作確認をできるようにする。
-- ローカルの message port が開くだけで、外部からは接続できない。
require("hs.ipc")

hs.hotkey.alertDuration = 0
hs.hints.showTitleThresh = 0
hs.window.animationDuration = 0

-----------------------------------------------------------------------------------
-- Move windows
units = {
	left50 = { x = 0.00, y = 0.00, w = 0.50, h = 1.00 },
	right50 = { x = 0.50, y = 0.00, w = 0.50, h = 1.00 },
	top50 = { x = 0.00, y = 0.00, w = 1.00, h = 0.50 },
	bottom50 = { x = 0.00, y = 0.50, w = 1.00, h = 0.50 },
	bottomright = { x = 0.40, y = 0.50, w = 0.60, h = 0.50 },
	full = { x = 0.00, y = 0.00, w = 1.00, h = 1.00 },
}

mash = { "alt", "shift", "ctrl" }
hs.hotkey.bind(mash, "h", function()
	hs.window.focusedWindow():move(units.left50, nil, true)
end)
hs.hotkey.bind(mash, "j", function()
	hs.window.focusedWindow():move(units.bottom50, nil, true)
end)
hs.hotkey.bind(mash, "k", function()
	hs.window.focusedWindow():move(units.top50, nil, true)
end)
hs.hotkey.bind(mash, "l", function()
	hs.window.focusedWindow():move(units.right50, nil, true)
end)
hs.hotkey.bind(mash, "b", function()
	hs.window.focusedWindow():move(units.bottomright, nil, true)
end)
hs.hotkey.bind(mash, "f", function()
	hs.window.focusedWindow():move(units.full, nil, true)
end)

-----------------------------------------------------------------------------------
-- Key mappings

--[[
-- Previous Version
local function keyCode(key, modifiers)
    modifiers = modifiers or {}
    return function()
        hs.eventtap.event.newKeyEvent(modifiers, string.lower(key), true):post()
        hs.timer.usleep(1000)
        hs.eventtap.event.newKeyEvent(modifiers, string.lower(key), false):post()
    end
end
local function remapKey(modifiers, key, keyCode)
    hs.hotkey.bind(modifiers, key, keyCode, nil, keyCode)
end

remapKey({"ctrl"}, "h", keyCode("left"))
remapKey({"ctrl"}, "j", keyCode("down"))
remapKey({"ctrl"}, "k", keyCode("up"))
remapKey({"ctrl"}, "l", keyCode("right"))
remapKey({"ctrl"}, "i", keyCode("left", {"cmd"}))
remapKey({"ctrl"}, "a", keyCode("right", {"cmd"}))
]]

local function pressFn(mods, key)
	if key == nil then
		key = mods
		mods = {}
	end
	return function()
		hs.eventtap.keyStroke(mods, key, 1000)
	end
end

local function remapKey(modifiers, key, pressFn)
	hs.hotkey.bind(modifiers, key, pressFn, nil, pressFn)
end

local function isGhostty()
	local app = hs.application.frontmostApplication()
	return app and app:name() == "Ghostty"
end

-- WezTerm が前面の間だけ無効化するリマップ。
-- hs.hotkey はシステム全体で先にキーを奪うため、同じキーを WezTerm 内の Herdr の
-- direct keybinding として使うものは前面判定で明示的に譲る必要がある。
--   ctrl+w       -> Herdr: focus_pane_down
--   ctrl+shift+w -> WezTerm: 新規ウィンドウ
--   ctrl+i       -> Herdr: previous_workspace (上の space へ)
--   ctrl+a       -> Herdr: 入力待ち agent の pane へ focus (keys.command)
local weztermYieldingRemaps = {
	{ mods = { "ctrl", "shift" }, key = "w", press = pressFn({ "alt", "shift" }, "left") },
	{ mods = { "ctrl" }, key = "w", press = pressFn({ "alt", "shift" }, "right") },
	{ mods = { "ctrl" }, key = "i", press = pressFn({ "cmd" }, "left") },
	{ mods = { "ctrl" }, key = "a", press = pressFn({ "cmd" }, "right") },
}

local weztermYieldingHotkeys = {}
for _, entry in ipairs(weztermYieldingRemaps) do
	table.insert(weztermYieldingHotkeys, hs.hotkey.bind(entry.mods, entry.key, entry.press, nil, entry.press))
end

local function updateWeztermYieldingHotkeys()
	local app = hs.application.frontmostApplication()
	local inWezTerm = app ~= nil and app:name() == "WezTerm"
	for _, hotkey in ipairs(weztermYieldingHotkeys) do
		if inWezTerm then
			hotkey:disable()
		else
			hotkey:enable()
		end
	end
end

-- watcher は GC されると通知が止まるのでグローバルに保持する
weztermAppWatcher = hs.application.watcher.new(function(_, eventType)
	if eventType == hs.application.watcher.activated then
		updateWeztermYieldingHotkeys()
	end
end)
weztermAppWatcher:start()
updateWeztermYieldingHotkeys()

-- remapKey({ "ctrl", "shift" }, "h", function()
-- 	if isGhostty() then
-- 		return false
-- 	end
-- 	pressFn({ "shift" }, "left")()
-- 	return true
-- end)
--
-- remapKey({ "ctrl", "shift" }, "l", function()
-- 	if isGhostty() then
-- 		return false
-- 	end
-- 	pressFn({ "shift" }, "right")()
-- 	return true
-- end)

remapKey({ "ctrl" }, "h", pressFn("left"))
remapKey({ "ctrl" }, "j", pressFn("down"))
remapKey({ "ctrl" }, "k", pressFn("up"))
remapKey({ "ctrl" }, "l", pressFn("right"))
-- ctrl+i (行頭) / ctrl+a (行末) は weztermYieldingRemaps 側で bind している

-- ctrl+, (下) / ctrl+. (上) でスクロール。
-- page key の代わりに本物のスクロールホイールイベントを送るので、行単位で動き、
-- WezTerm (Herdr) だけでなくブラウザなど全アプリで効く。Herdr は
-- mouse_capture = true でホイールを受け取り、[ui] mouse_scroll_lines (既定 3) 行ずつ
-- pane scrollback を動かす。
--
-- キーをグローバルに奪うので競合の少ない ctrl+, / ctrl+. を使う。macOS の環境設定は
-- cmd+, なので GUI アプリと衝突せず、`,` / `.` には legacy control code が無いので
-- shell や TUI が既定で bind することもない (Herdr の tab 移動も ctrl+y / ctrl+o へ
-- 移したので空いている)。
--
-- ホイールイベントの配送先はキーボードフォーカスではなく**マウスポインタの位置**で
-- 決まる。CGEvent の location を書き換えても HID tap 経由の post では無視され、
-- 特定 pid への post (CGEventPostToPid) も mouse 系イベントでは配送されないことが
-- 多いので、どちらも使わずに素の post だけを行う。
-- したがってスクロール対象は「ポインタの下にあるもの」になる。ポインタが前面
-- ウィンドウの外にある時だけ、一時的にウィンドウ中心へ移してから post する
-- (window server が非同期に hit-test するので、戻すのは少し遅らせる)。
-- Herdr で pane を分割している場合はフォーカス中の pane ではなくポインタの下の pane が
-- 動く。フォーカス基準で確実に動かしたい時は素の pageup / pagedown を使う
-- (Herdr は修飾なしの page key を intercept する)。
local SCROLL_LINES = 3

local function insideFrame(point, frame)
	return point.x >= frame.x
		and point.x <= frame.x + frame.w
		and point.y >= frame.y
		and point.y <= frame.y + frame.h
end

local function scrollFn(lines)
	return function()
		local win = hs.window.focusedWindow()
		local frame = win and win:frame()
		local origin = hs.mouse.absolutePosition()

		local warped = false
		if frame and not insideFrame(origin, frame) then
			hs.mouse.absolutePosition({ x = frame.x + frame.w / 2, y = frame.y + frame.h / 2 })
			warped = true
		end

		hs.eventtap.event.newScrollEvent({ 0, lines }, {}, "line"):post()

		if warped then
			hs.timer.doAfter(0.05, function()
				hs.mouse.absolutePosition(origin)
			end)
		end
	end
end

remapKey({ "ctrl" }, ",", scrollFn(-SCROLL_LINES))
remapKey({ "ctrl" }, ".", scrollFn(SCROLL_LINES))

----------------------------------------------------------------------------------------------------
-- Open terminal with Second Alt(Option)
firstAlt = false
secondAlt = false

local function cancelAlt()
	firstAlt = false
	secondAlt = false
end

local function changeTerminal(event)
	local c = event:getKeyCode()
	local f = event:getFlags()
	if event:getType() == hs.eventtap.event.types.flagsChanged then
		if f["alt"] then
			if c == 58 or c == 61 then
				if firstAlt then
					secondAlt = true
				end
				firstAlt = true
				hs.timer.doAfter(0.5, function()
					cancelAlt()
				end)
				if firstAlt and secondAlt then
					cancelAlt()
					hs.application.launchOrFocus("/Applications/WezTerm.app")
				end
			else
				cancelAlt()
			end
		end
	end
end

opop = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, changeTerminal)
opop:start()
