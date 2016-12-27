-- Triggers
--   For triggers with no home
-----------------------------------------------
local triggers = {}

-- Add triggers
-----------------------------------------------
triggers.triggers = {}
triggers.triggers["Window Hints"] = hs.hints.windowHints
triggers.triggers["Hammerspoon Console"] = hs.toggleConsole
triggers.triggers["Hammerspoon Reload"] = hs.reload
triggers.triggers["Hammerspoon Docs"] = hs.hsdocs

triggers.triggers["Defeat Paste Blocking"] = function() hs.eventtap.keyStrokes(hs.pasteboard.getContents()) end

----------------------------------------------------------------------------
return triggers
