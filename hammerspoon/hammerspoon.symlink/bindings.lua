
-- Default bindings
--   Overide: config.lua.example --> config.lua
-----------------------------------------------
local bindings = {}
local keys = {}


-- Key Bindings
-----------------------------------------------
keys.modifiers = {
  ['cmd'] = {"cmd"},
  ['mash'] = {"ctrl", "alt", "cmd"},
  ['alt'] = {"alt"},
}

-- Set up hotkeys
-----------------------------------------------
keys.triggers = {

  -- Apps
  -----------------------------------------------
  ["Autohide Toggle"] = { "mash", "F13" },
  ["Reset App Locations"] = { "mash", "F14" },

  ["Hammerspoon Console"] = { "mash", "\\" },
  ["Hammerspoon Reload"] = { "mash", "R", false },
  ["Hammerspoon Docs"] = { "mash", "`" },

  ["Terminal Toggle"] = { "cmd", "§" },

  -- Audio
  -----------------------------------------------
  ["Spotify What Track"] = { "mash", "w" },

  -- Keyboard
  -----------------------------------------------
  ["Keyboard Help"] = { "mash", "/", false },

  -- Misc
  -----------------------------------------------
  ["Test Something"] = { "mash", "t", false },
  ["Anycomplete"] = { "mash", "a" },
  ["Defeat Paste Blocking"] = { "mash", "v" },
  ["Scratchpad Toggle"] = { "mash", "Space" },

  -- System
  -----------------------------------------------
  -- ["Bluetooth Toggle"] = { "mash", "E" },
  ["Caffeine Toggle"] = { "mash", "," },

  ["System Lock"] = { "mash", "l" },
  ["System Screensaver"] = { "mash", "F6" },
  ["System Sleep"] = { "mash", "s" },

  ["Show Date And Time"] = { "mash", "d" },

  ["WiFi Toggle"] = { "mash", "F5" },

  ["Window Hints"] = { "mash", "." },

  -- Window management Hotkeys
  -----------------------------------------------

  -- Center current window
  ["Window Toggle Center"] = { "mash", "c" },

  -- Resize current window to maximise or fullscreen
  ["Window Toggle Maximise"] = { "mash", "m" },
  ["Window Toggle Fullscreen"] = { "mash", "f" },

  -- Resize current window to half of the screen
  ["Window Half Left"]   = { "mash", "h" },
  ["Window Half Right"]  = { "mash", "k" },
  ["Window Half Top"]    = { "mash", "u" },
  ["Window Half Bottom"] = { "mash", "j" },

  -- Push current window around the grid
  ["Window Push Left"]  = { "mash", "Left" },
  ["Window Push Right"] = { "mash", "Right" },
  ["Window Push Up"]    = { "mash", "Up" },
  ["Window Push Down"]  = { "mash", "Down" },

  -- Resize current window to grid
  ["Window Resize Thinner"] = { "mash", "[" },
  ["Window Resize Wider"]   = { "mash", "]" },
  ["Window Resize Taller"]  = { "mash", "=" },
  ["Window Resize Shorter"] = { "mash", "'" },

  -- Move current window to next/prev display
  ["Window Next Screen"] = { "mash", "0" },

  -- Show interactive grid
  ["Window Show Grid"] = { "mash", "§" },


}

----------------------------------------------------------------------------
bindings.keys = keys

return bindings
