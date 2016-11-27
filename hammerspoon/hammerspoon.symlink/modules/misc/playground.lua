
-- Playground
--   A place for trying stuff out
-----------------------------------------------
local playground = {}
local alert = jspoon.utils.alert

-- Toggle an application:
-- if frontmost: hide it. if not: activate/launch it
-----------------------------------------------

function playground.testSomething()
  alert.simple(hs.host.operatingSystemVersionString())
end


-- Add triggers
-----------------------------------------------
playground.triggers = {}
playground.triggers["Test Something"] = playground.testSomething

----------------------------------------------------------------------------
return playground
