-- System
--   Child Lock
-----------------------------------------------
local m = {}
local alert = require('hs.alert').show

-- Configuration
m.config = {
  isActiveKey = 'jspoon_childlock',
  menupriority = 1290,
  cursor = "🦄",
  cursorSize = 64,
  blameText = "👶 Zoë typed",
  idleThreshold = 60,  -- 1 minute
  unlockHotkey = { mods = { "ctrl", "alt", "cmd" }, key = "u" },
  checkInterval = 10,    -- how often to check for idle time
  message = {
    on = 'Childlock enabled',
    off = 'Childlock disabled'
  },
  icon = {
    on = "assets/icons/childlock/on.png",
    off = "assets/icons/childlock/off.png"
  }
}

-- Disable by default
m.enabled = false

local modSymbols = {
  cmd = "⌘",
  shift = "⇧",
  alt = "⌥",
  option = "⌥",  -- alias
  ctrl = "⌃",
  control = "⌃", -- alias
  fn = "fn"
}

-- Internal state
local lockActive = false
local idleTimer = nil
local keyInterceptor = nil
local mouseInterceptor = nil
local customCursor = nil
local mouseTracker = nil
local cursorHiderOverlays = {}
local lockOverlays = {}
local recordedKeys = ""

m.isUnlockCombo = function(event)
  local key = hs.keycodes.map[event:getKeyCode()]
  local flags = event:getFlags()
  local configKey = m.config.unlockHotkey.key:lower()

  -- Check key + modifiers match
  if key ~= configKey then return false end
  for _, mod in ipairs(m.config.unlockHotkey.mods) do
    if not flags[mod] then return false end
  end
  return true
end

m.formatHotkey = function(mods, key)
  local parts = {}
  for _, mod in ipairs(mods) do
    table.insert(parts, modSymbols[mod] or mod)
  end
  table.insert(parts, key:upper())
  return table.concat(parts, " + ")
end

-- Helper: activate child lock state
m.activateLock = function()
  if lockActive then return end
  lockActive = true

  -- Block all keypresses
  keyInterceptor = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
    local char = event:getCharacters(true) or ""
    alert(m.formatHotkey({}, char))
    -- m.log.w(event:getFlags())
    if m.isUnlockCombo(event) then return false end

    recordedKeys = recordedKeys .. char
    return true
  end)
  keyInterceptor:start()

  -- Block mouse events
  mouseInterceptor = hs.eventtap.new({
    hs.eventtap.event.types.leftMouseDown,
    hs.eventtap.event.types.leftMouseUp,
    hs.eventtap.event.types.rightMouseDown,
    hs.eventtap.event.types.rightMouseUp,
    hs.eventtap.event.types.mouseMoved,
    hs.eventtap.event.types.scrollWheel,
    hs.eventtap.event.types.otherMouseDown,
    hs.eventtap.event.types.otherMouseUp
  }, function(event)
    return true -- block all mouse input
  end)
  -- mouseInterceptor:start()

  -- Create overlays for all screens
  for _, screen in ipairs(hs.screen.allScreens()) do
    local instructionText = "Press " .. m.formatHotkey(m.config.unlockHotkey.mods, m.config.unlockHotkey.key) .. " to unlock"
    local frame = screen:frame()
    local overlay = hs.canvas.new(frame):show()
    local textWidth = 600
    local textHeight = 50

    overlay[1] = {
      type = "rectangle",
      action = "fill",
      fillColor = { red = 0, green = 0, blue = 0, alpha = 0.85 }
    }

    overlay[2] = {
      type = "text",
      text = "👶 Child Lock Active 🔒",
      textSize = 48,
      textColor = { white = 1 },
      textAlignment = "center",
      frame = {
        x = (frame.w - 600) / 2,
        y = (frame.h / 2) - 60,
        w = 600,
        h = 60
      }
    }

    -- Instruction
    overlay[3] = {
      type = "text",
      text = instructionText,
      textSize = 24,
      textColor = { white = 0.65 },
      textAlignment = "center",
      frame = {
        x = (frame.w - 400) / 2,
        y = (frame.h / 2) + 10,
        w = 400,
        h = 40
      }
    }

    table.insert(lockOverlays, overlay)
  end

  -- Show a floating emoji cursor
  local pos = hs.mouse.absolutePosition()
  customCursor = hs.canvas.new({
    x = pos.x - m.config.cursorSize,
    y = pos.y - m.config.cursorSize,
    w = m.config.cursorSize,
    h = m.config.cursorSize
  }):appendElements({
    type = "text",
    text = m.config.cursor,
    textSize = m.config.cursorSize,
    textColor = { white = 1 },
    textAlignment = "right"
  }):level(hs.canvas.windowLevels.cursor + 1):show()

  -- Follow the mouse
  mouseTracker = hs.timer.doEvery(0.05, function()
    local pos = hs.mouse.absolutePosition()
    if customCursor then
      customCursor:topLeft({ x = pos.x - m.config.cursorSize, y = pos.y - m.config.cursorSize })
    end
  end)

end

-- Helper: deactivate child lock state
m.deactivateLock = function()
  if not lockActive then return end
  lockActive = false

  if keyInterceptor then
    keyInterceptor:stop()
    keyInterceptor = nil
  end

  if lockOverlays then
    for _, overlay in ipairs(lockOverlays) do
      overlay:delete()
    end
    lockOverlays = {}
  end

  if mouseInterceptor then
    mouseInterceptor:stop()
    mouseInterceptor = nil
  end

  if customCursor then
    customCursor:delete()
    customCursor = nil
  end

  if mouseTracker then
    mouseTracker:stop()
    mouseTracker = nil
  end

  -- Remove transparent overlays
  for _, overlay in ipairs(cursorHiderOverlays) do
    overlay:delete()
  end
  cursorHiderOverlays = {}

  -- Show alert
  if #recordedKeys > 0 then
    hs.alert("⚠️ " .. #recordedKeys .. " key(s) were mashed while you were away")
    hs.alert(m.config.blameText .. ": \"" .. recordedKeys .. "\"")
  end

  recordedKeys = ""
end

-- Get the state key, used in config for messages and menubar icons
m.getStateKey = function(state) return state and 'on' or 'off' end

-- Helper: toggle childlock state
m.toggleState = function()
  if(m.enabled) then
    m.setState(false)
  else
    m.setState(true)
  end
end

-- Start child lock
m.start = function()
  m.menubar = hs.menubar.new(true, 'childlock')
  -- Idle checker
  if idleTimer then idleTimer:stop() end
  idleTimer = hs.timer.doEvery(m.config.checkInterval, function()
    if m.enabled and not lockActive and hs.host.idleTime() > m.config.idleThreshold then
      m.activateLock()
    end
  end)

  -- Unlock hotkey
  hs.hotkey.bind(m.config.unlockHotkey.mods, m.config.unlockHotkey.key, function()
    m.deactivateLock()
  end)

  local persistedState = hs.settings.get(m.config.isActiveKey)
  if m.menubar then
    m.log.i('Persisted state was ' .. m.getStateKey(persistedState))
    -- Set the click handler
    m.menubar:setClickCallback(m.toggleState)
    m.menubar:setTooltip('Child Lock')
    -- Set the state
    m.setState(persistedState)
  end
end

-- Sets and persists the state
m.setState = function(state)
    local stateKey = m.getStateKey(state)
    -- Set menubar icon
    m.menubar:setIcon(hs.image.imageFromPath(m.config.icon[stateKey]):setSize({w=16,h=16}))
    -- Log state to console
    m.log.i('Setting to ' .. stateKey)
    -- Alert message to user
    alert(m.config.message[stateKey])
    -- Set the state
    m.enabled = state
    -- Persist the state across sessions
    hs.settings.set(m.config.isActiveKey, state)
end
-- Add triggers
-----------------------------------------------
m.triggers = {}
m.triggers["Child Lock Activate"] = m.activateLock
m.triggers["Child Lock Deactivate"] = m.deactivateLock
m.triggers["Child Lock Toggle"] = m.toggleState

----------------------------------------------------------------------------
return m