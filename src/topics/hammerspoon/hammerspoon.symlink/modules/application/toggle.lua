
-- Toggle an application:
-- if frontmost: hide it. if not: activate/launch it
-----------------------------------------------
local m = {}

m.toggleApp = function(appName)
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
m.triggers = {}
m.triggers["Terminal Toggle"] = function() m.toggleApp("iTerm") end

----------------------------------------------------------------------------
return m
