
-- System
--   Mac system related functions
-----------------------------------------------
local system = {}


-- Add triggers
-----------------------------------------------
system.triggers = {}
system.triggers["System Lock"] = hs.caffeinate.lockScreen
system.triggers["System Sleep"] = hs.caffeinate.systemSleep
system.triggers["System Screensaver"] = hs.caffeinate.startScreensaver

----------------------------------------------------------------------------
return system
