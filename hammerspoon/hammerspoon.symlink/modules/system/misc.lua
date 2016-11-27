
-- Misc system related tasks
-----------------------------------------------
local system = {}
local alert = jspoon.utils.alert

-- Show the date and time
-----------------------------------------------
function system.showDateAndTime()
    alert.simple(os.date("It's %R on %B %e, %G"))
end


-- Add triggers
-----------------------------------------------
system.triggers = {}
system.triggers["Show Date And Time"] = system.showDateAndTime

----------------------------------------------------------------------------
return system
