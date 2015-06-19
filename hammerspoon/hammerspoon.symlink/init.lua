
-- Thanks to:
--  https://github.com/voostindie/hammerspoon-config
------------------------------------------------

-----------------------------------------------
-- Includes
-----------------------------------------------

require "caffeine"
require "misc"
require "notify"
require "spotify"
require "terminal"
require "window-management"


-- Let us know we've got the latest and greatest
------------------------------------------------
notify("(Re)loaded Hammerspoon config")


-----------------------------------------------
-- Set up hotkeys
-----------------------------------------------

local cmd  = {"cmd"}
local mash = {"cmd", "alt", "ctrl"}
local alt  = {"alt"}



-- Misc Hotkeys
-----------------------------------------------

hs.hotkey.bind(cmd,  "§", function() toggleTerminal() end)
hs.hotkey.bind(mash, ".", function() showDateAndTime() end)
hs.hotkey.bind(mash, "r", function() reloadConfig() end)


-- Window management Hotkeys
-----------------------------------------------

hs.hotkey.bind(mash, "w", spotifyWhatTrack)
hs.hotkey.bind(mash, ",", function() caffeineClicked() end)


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

-- Move current window to quarter of the screen using u,i,j,k
hs.hotkey.bind(mash, "u",  function() windowResize(.5,.5, 0, 0) end)
hs.hotkey.bind(mash, "i",  function() windowResize(.5,.5,.5, 0) end)
hs.hotkey.bind(mash, "j",  function() windowResize(.5,.5, 0,.5) end)
hs.hotkey.bind(mash, "k",  function() windowResize(.5,.5,.5,.5) end)
-- Make current window larger/smaller
hs.hotkey.bind(mash, "=",  function() windowIncrement(20,true) end)
hs.hotkey.bind(mash, "-",  function() windowIncrement(20,false) end)

-- TODO: Move current window to next/prev third
-- Move current window to next/prev display
hs.hotkey.bind(mash, "[",  function() windowMoveToScreen('prev') end)
hs.hotkey.bind(mash, "]",  function() windowMoveToScreen('next') end)

-- TODO: Undo/redo

