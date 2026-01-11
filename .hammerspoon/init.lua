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

remapKey({ "ctrl", "shift" }, "w", pressFn({ "alt", "shift" }, "left"))
remapKey({ "ctrl" }, "w", pressFn({ "alt", "shift" }, "right"))

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
remapKey({ "ctrl" }, "i", pressFn({ "cmd" }, "left"))
remapKey({ "ctrl" }, "a", pressFn({ "cmd" }, "right"))

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
					hs.application.launchOrFocus("/Applications/Ghostty.app")
				end
			else
				cancelAlt()
			end
		end
	end
end

opop = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, changeTerminal)
opop:start()
