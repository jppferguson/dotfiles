
-- System
--   Mac system related functions
-----------------------------------------------
local system = {}


-- Lock Mac
-----------------------------------------------
function system.lock()
    os.execute("/System/Library/CoreServices/Menu\\ Extras/User.menu/Contents/Resources/CGSession -suspend")
end

-- Add triggers
-----------------------------------------------
system.triggers = {}
system.triggers["Lock Mac"] = system.lock

----------------------------------------------------------------------------
return system
