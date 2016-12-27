
-- Global Namespace
-----------------------------------------------
jspoon = {}
jspoon.utils = {}
jspoon.loadedModules = {}

jspoon.log = require("utils.log")
jspoon.fn = require("utils.functions")


-- Config
---- Load default first, overrides second
-----------------------------------------------
local config = {
  bindings = require('bindings'),
  global = {},
}

-- Overide config with local file
jspoon.fn.configOveride(config)

-- Set global config
jspoon.config = config.global


-- Logging and custom utilities
-----------------------------------------------
jspoon.utils.alert = require("utils.alert")
jspoon.utils.keys = require("utils.keys")
jspoon.utils.load = require("utils.load")
jspoon.utils.misc = require("utils.misc")
jspoon.utils.watch = require("utils.watch")

-- Modules to load
-----------------------------------------------
local modules = {
  "application.toggle",
  "audio.headphones",
  "audio.music",
  "keyboard.shortcuts",
  "misc.anycomplete",
  "misc.playground",
  "misc.scratchpad",
  "misc.triggers",
  "misc.weather",
  "system.caffeine",
  "system.clipboard",
  "system.controls",
  "system.misc",
  "system.nightshift",
  "system.wifi",
  "window.management",
}

-- Load, configure, and start each module
-----------------------------------------------
jspoon.loadedModules = jspoon.utils.load.all(modules)
jspoon.utils.load.applyAllConfig(jspoon.loadedModules)
jspoon.utils.load.startAll(jspoon.loadedModules)
jspoon.utils.keys.getTriggersFromModules(jspoon.loadedModules)
jspoon.utils.keys.setModifiers(config.bindings.keys.modifiers)
jspoon.utils.keys.bindAll(config.bindings.keys.triggers)
jspoon.utils.keys.activate()

-- Watch config for file changes
-----------------------------------------------
jspoon.utils.watch.configPath("bindings.lua")
jspoon.utils.watch.configPath("config.lua")
jspoon.utils.watch.configPath("init.lua")
jspoon.utils.watch.configPath("modules/")
jspoon.utils.watch.configPath("utils/")

-- Let us know we've got the latest and greatest
------------------------------------------------
jspoon.utils.alert.onScreen("(Re)loaded Hammerspoon config")
