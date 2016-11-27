
-- Helper functions
-----------------------------------------------
local fn = {}


-- Deep merge a table
-----------------------------------------------
function fn.merge(t1, t2)
    for k, v in pairs(t2) do
        if (type(v) == "table") and (type(t1[k] or false) == "table") then
            fn.merge(t1[k], t2[k])
        else
            t1[k] = v
        end
    end
    return t1
end


-- Overide config with ./config.lua if available
-----------------------------------------------
function fn.configOveride(defaults)
  local config = {}
  local configFile = 'config'
  if(hs.fs.fileUTI(configFile .. '.lua')) then
    config = require(configFile)
  end
  return fn.merge(defaults, config)
end

----------------------------------------------------------------------------
return fn
