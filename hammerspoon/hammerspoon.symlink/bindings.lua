
-- Default bindings
--   Overide: config.lua.example --> config.lua
-----------------------------------------------
local bindings = {}
local keys = {}


-- Key Bindings
-----------------------------------------------
keys.modifiers = {
  ['cmd'] = {"cmd"},
  ['mash'] = {"cmd", "alt", "ctrl"},
  ['alt'] = {"alt"},
}

-- Set up hotkeys
-----------------------------------------------
keys.triggers = {

  -- Apps
  -----------------------------------------------
  -- ["Hammerspoon Console"] = { "cmd", "4" },
  -- ["Hammerspoon Reload Config"] = { "cmd", "R" },
  -- ["Hammerspoon Status"] = { "cmd", "\\" },

  ["Terminal Toggle"] = { "cmd", "§" },

  -- Audio
  -----------------------------------------------
  ["Spotify What Track"] = { "mash", "w" },

  -- Misc
  -----------------------------------------------
  ["Test Something"] = { "mash", "t" },

  -- System
  -----------------------------------------------
  -- ["Bluetooth Toggle"] = { "mash", "E" },
  ["Caffeine Toggle"] = { "mash", "," },

  ["Lock Mac"] = { "mash", "l" },
  -- ["Sleep Mac"] = { "mash", "s" },

  ["Show Date And Time"] = { "mash", "." },

  ["WiFi Toggle"] = { "mash", "e" },
  ["WiFi Status"] = { "mash", "r" },

  ["Window Hints"] = { "mash", "/" },

  -- Window management Hotkeys
  -----------------------------------------------

  -- Center current window
  ["Window Center"] = { "mash", "c" },

  -- Resize current window to maximise or fullscreen
  ["Window Maximise"] = { "mash", "m" },
  ["Window Toggle Fullscreen"] = { "mash", "f" },

  -- Resize current window to half of the screen using arrow keys
  ["Window Half Left"]   = { "mash", "Left" },
  ["Window Half Right"]  = { "mash", "Right" },
  ["Window Half Top"]    = { "mash", "Up" },
  ["Window Half Bottom"] = { "mash", "Down" },

  -- Move current window to quarter of the screen using u,i,j,k
  ["Window Quarter Top Left"]     = { "mash", "u" },
  ["Window Quarter Top Right"]    = { "mash", "i" },
  ["Window Quarter Bottom Right"] = { "mash", "j" },
  ["Window Quarter Bottom Left"]  = { "mash", "k" },

  -- Make current window larger/smaller
  ["Window Larger"]  = { "mash", "=" },
  ["Window Smaller"] = { "mash", "-" },

  -- Move current window to next/prev display
  ["Window Previous Screen"] = { "mash", "[" },
  ["Window Next Screen"] = { "mash", "]" }

}

----------------------------------------------------------------------------
bindings.keys = keys

return bindings
