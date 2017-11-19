local load = {}
local config = jspoon.config
local strUtil = require('utils.string')

-- load a module from modules/ dir, and set up a logger for it
function load.moduleByName(moduleName)
  -- TODO: check if module file actually exists, and warn but dont fall over
  jspoon.loadedModules[moduleName] = require('modules.' .. moduleName)
  jspoon.loadedModules[moduleName].name = moduleName
  jspoon.loadedModules[moduleName].log = hs.logger.new(moduleName, config.loglevel)
  jspoon.loadedModules[moduleName].log.i(jspoon.loadedModules[moduleName].name .. ': module loaded')
end

-- function load.moduleByName(moduleName, moduleParent)
--   local module = {}
--   if (type(moduleName) == "table")) then
--     load.all(moduleName, moduleParent)
--   else
--     module = require('modules.' .. moduleName)
--     module.name = moduleName
--     module.log = hs.logger.new(moduleName, config.loglevel)
--     module.log.i(module.name .. ': module loaded')
--   end
--   jspoon.loadedModules[moduleName] = module
-- end

-- recursively loop through directory to get array of available modules
function load.allFromDirectory(dir)
  local modules = {}

  for file in require("hs.fs").dir(os.getenv("HOME") .. "/.hammerspoon/modules/" .. dir) do
    if not strUtil.beginsWith(file, '.') then
      local filepath = dir .. "/" .. file
      if file:find(".lua") then
        filepath = strUtil.chopEnding(filepath, ".lua")
        filepath = strUtil.chopBeginning(filepath, "/")
        filepath = string.gsub(filepath, "/", ".")
        table.insert(modules, filepath)
      else
        jspoon.fn.arrayAdd(modules, load.allFromDirectory(filepath))
      end
    end
  end
  return modules
end

-- save the configuration of a module in the module object
function load.moduleConfig(module)
  module.config = module.config or {}
  if (config[module.name]) then
    jspoon.fn.merge(module.config, config[module.name])
    module.log.i(module.name .. ': module configured')
  end
end

-- start a module
function load.moduleStart(module)
  if module.start == nil then return end
  module.start()
  module.log.i(module.name .. ': module started')
end

-- stop a module
function load.moduleStop(module)
  if module.stop == nil then return end
  module.stop()
  module.log.i(module.name .. ': module stopped')
end

-- global function to stop modules and reload hammerspoon config
function load.reload()
  -- hs.fnutils.each(jspoon.loadedModules, stopModule)
  hs.reload()
end


-- load a list of modules
function load.all(moduleList)
  local modules = moduleList or jspoon.loadedModules
  hs.fnutils.each(modules, load.moduleByName)
  return jspoon.loadedModules
end

function load.startAll(moduleList)
  local modules = moduleList or jspoon.loadedModules
  hs.fnutils.each(modules, load.moduleStart)
end

function load.applyAllConfig(moduleList)
  local modules = moduleList or jspoon.loadedModules
  hs.fnutils.each(modules, load.moduleConfig)
end

function load.stopAll(moduleList)
  local modules = moduleList or jspoon.loadedModules
  hs.fnutils.each(modules, load.moduleStop)
end

----------------------------------------------------------------------------
return load
