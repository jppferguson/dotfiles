
-- Toggle an application:
-- if frontmost: hide it. if not: activate/launch it
-----------------------------------------------
local toggle = {}

function toggle.app(appName)
    local app = hs.appfinder.appFromName(appName)
    if not app or app:isHidden() then
        hs.application.launchOrFocus(appName)
    elseif hs.application.frontmostApplication() ~= app then
        app:activate()
    else
        app:hide()
    end
end


-- Add triggers
-----------------------------------------------
toggle.triggers = {}
toggle.triggers["Terminal Toggle"] = function() toggle.app("iTerm") end

----------------------------------------------------------------------------
return toggle
