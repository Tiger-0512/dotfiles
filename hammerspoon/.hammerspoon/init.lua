hs.hotkey.alertDuration = 0
hs.hints.showTitleThresh = 0
hs.window.animationDuration = 0

-- Use the standardized config location, if present
custom_config = hs.fs.pathToAbsolute(os.getenv("HOME") .. "/.config/hammerspoon/private/config.lua")
if custom_config then
    print("Loading custom config")
    dofile( os.getenv("HOME") .. "/.config/hammerspoon/private/config.lua")
    privatepath = hs.fs.pathToAbsolute(hs.configdir .. "/private/config.lua")
    if privatepath then
        hs.alert("You have config in both .config/hammerspoon and .hammerspoon/private.\nThe .config/hammerspoon one will be used.")
    end
else
    -- otherwise fallback to "classic" location.
    if not privatepath then
        privatepath = hs.fs.pathToAbsolute(hs.configdir .. "/private")
        -- Create `~/.hammerspoon/private` directory if not exists.
        hs.fs.mkdir(hs.configdir .. "/private")
    end
    privateconf = hs.fs.pathToAbsolute(hs.configdir .. "/private/config.lua")
    if privateconf then
        -- Load awesomeconfig file if exists
        require("private/config")
    end
end

hsreload_keys = hsreload_keys or {{"cmd", "shift", "ctrl"}, "R"}
if string.len(hsreload_keys[2]) > 0 then
    hs.hotkey.bind(hsreload_keys[1], hsreload_keys[2], "Reload Configuration", function() hs.reload() end)
end

-- ModalMgr Spoon must be loaded explicitly, because this repository heavily relies upon it.
hs.loadSpoon("ModalMgr")

-- Load those Spoons
for _, v in pairs(hspoon_list) do
    hs.loadSpoon(v)
end


----------------------------------------------------------------------------------------------------
-- Register lock screen
hslock_keys = hslock_keys or {"alt", "L"}
if string.len(hslock_keys[2]) > 0 then
    spoon.ModalMgr.supervisor:bind(hslock_keys[1], hslock_keys[2], "Lock Screen", function()
        hs.caffeinate.lockScreen()
    end)
end


----------------------------------------------------------------------------------------------------
units = {
    left50 = {x=0.00, y=0.00, w=0.50, h=1.00},
    right50 = {x=0.50, y=0.00, w=0.50, h=1.00},
    top50 = {x=0.00, y=0.00, w=1.00, h=0.50},
    bottom50 = {x=0.00, y=0.50, w=1.00, h=0.50},
    bottomright = {x=0.40, y=0.50, w=0.60, h=0.50},
    full = {x=0.00, y=0.00, w=1.00, h=1.00}
}

mash = {"alt", "shift", "ctrl"}
hs.hotkey.bind(mash, "h", function() hs.window.focusedWindow():move(units.left50, nil, true) end)
hs.hotkey.bind(mash, "j", function() hs.window.focusedWindow():move(units.bottom50, nil, true) end)
hs.hotkey.bind(mash, "k", function() hs.window.focusedWindow():move(units.top50, nil, true) end)
hs.hotkey.bind(mash, "l", function() hs.window.focusedWindow():move(units.right50, nil, true) end)
hs.hotkey.bind(mash, "b", function() hs.window.focusedWindow():move(units.bottomright, nil, true) end)
hs.hotkey.bind(mash, "f", function() hs.window.focusedWindow():move(units.full, nil, true) end)


----------------------------------------------------------------------------------------------------
-- Initialize ModalMgr supervisor
spoon.ModalMgr.supervisor:enter()


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
                    hs.application.launchOrFocus("/Applications/Alacritty.app")
                end
            else
                cancelAlt()
            end
        end
    end
end
opop = hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, changeTerminal)
opop:start()


----------------------------------------------------------------------------------------------------
-- Key map settings
-- Cited from: http://shtaxxx.hatenablog.com/entry/2017/01/22/141831
--[[
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
]]

local function pressFn(mods, key)
    if key == nil then
        key = mods
        mods = {}
    end
    return function() hs.eventtap.keyStroke(mods, key, 1000) end
end
local function remapKey(modifiers, key, pressFn)
    hs.hotkey.bind(modifiers, key, pressFn, nil, pressFn)
end

remapKey({"ctrl", "shift"}, "w", pressFn({"alt", "shift"}, "left"))
remapKey({"ctrl"}, "w", pressFn({"alt", "shift"}, "right"))

remapKey({"ctrl", "shift"}, "h", pressFn({"shift"}, "left"))
remapKey({"ctrl", "shift"}, "l", pressFn({"shift"}, "right"))

remapKey({"ctrl"}, "h", pressFn("left"))
remapKey({"ctrl"}, "j", pressFn("down"))
remapKey({"ctrl"}, "k", pressFn("up"))
remapKey({"ctrl"}, "l", pressFn("right"))
remapKey({"ctrl"}, "i", pressFn({"cmd"}, "left"))
remapKey({"ctrl"}, "a", pressFn({"cmd"}, "right"))
