
-- Thanks to:
--  https://github.com/voostindie/hammerspoon-config
------------------------------------------------


-- Let us know we've got the latest and greatest
------------------------------------------------
hs.alert("(Re)loaded Hammerspoon config", 1)


-----------------------------------------------
-- Includes
-----------------------------------------------

require "misc"
require "terminal"
require "window-management"


-----------------------------------------------
-- Set up hotkeys
-----------------------------------------------

local cmd  = {"cmd"}
local mash = {"cmd", "alt", "ctrl"}
local alt  = {"alt"}



-- Misc Hotkeys
-----------------------------------------------

hs.hotkey.bind(cmd,  "§", function() toggleTerminal() end)
hs.hotkey.bind(mash, "-", function() showDateAndTime() end)
hs.hotkey.bind(mash, "r", function() reloadConfig() end)


-- Window management Hotkeys
-----------------------------------------------

-- Center current window
hs.hotkey.bind(mash, "c", windowCenter)

-- Resize current window to maximise or fullscreen
hs.hotkey.bind(mash, "m",  function() windowResize( 1, 1, 0, 0) end)
hs.hotkey.bind(mash, "f",  function() windowToggleFullscreen() end)

-- Resize current window to half of the screen using arrow keys
hs.hotkey.bind(mash, "Left",  function() windowResize(.5, 1, 0, 0) end)
hs.hotkey.bind(mash, "Right", function() windowResize(.5, 1,.5, 0) end)
hs.hotkey.bind(mash, "Up",    function() windowResize( 1,.5, 0, 0) end)
hs.hotkey.bind(mash, "Down",  function() windowResize( 1,.5, 0,.5) end)

-- Make current window larger/smaller
hs.hotkey.bind(mash, "=",  function() windowIncrement(20,true) end)
hs.hotkey.bind(mash, "-",  function() windowIncrement(20,false) end)

-- TODO: Move current window to next/prev display
-- TODO: Move current window to next/prev third
-- TODO: Move current window to next/prev quarter
-- TODO: Undo/redo

