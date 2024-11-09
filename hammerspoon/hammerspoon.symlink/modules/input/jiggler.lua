
-- Mouse
--   Jiggle the mouse every x seconds
-----------------------------------------------
local m = {}
local hotkey = require "hs.hotkey"
local alert = require "hs.alert"
local isActive = true
local lastCheckedMousePosition = hs.mouse.absolutePosition()

m.config = {
  isActiveKey = 'jspoon_jiggler',
  durationInMillis = 150,
  frequencyInSeconds = 120,
  message = {
    enabled = 'Circus Enabled',
    disabled = 'Circus Disabled',
  },
}

-- Set the jiggler state
m.setState = function(state)
  local stateString = state and 'enabled' or 'disabled'
  alert.show(m.config.message[stateString])
  -- save the state
  isActive = state
  -- Persist the state across sessions
  hs.settings.set(m.config.isActiveKey, state)
end

-- Set the jiggler state
m.getState = function()
  -- if not true == hs.caffeinate.get("displayIdle") then
  --   return false
  -- end
  return isActive
end

-- Toggle the jiggler state
m.toggle = function(skipState)
  if not skipState then
    m.setState(not isActive)
  end

  if isActive then
    hs.timer.doWhile(m.getState, m.jiggle, m.config.frequencyInSeconds)
  end
end

m.jiggle = function()
  local initialMouse = hs.mouse.absolutePosition()
  local currentMouse = initialMouse

  if math.floor(lastCheckedMousePosition.x) == math.floor(currentMouse.x) and math.floor(lastCheckedMousePosition.y) == math.floor(currentMouse.y) then
    -- alert.show("Mouse has not moved")
    lastCheckedMousePosition = currentMouse
    -- currentMouse = m.jiggleStep(currentMouse, 0, 20)
    -- currentMouse = m.jiggleStep(currentMouse, 30, 40)
    -- currentMouse = m.jiggleStep(currentMouse, -50, 50)
    -- currentMouse = m.jiggleStep(currentMouse, 20, -110)
    hs.eventtap.keyStroke({"ctrl", "alt", "cmd"}, "d")
  end
  lastCheckedMousePosition = currentMouse
end

-- Move the mouse from its current position by x,y
m.jiggleStep = function(currentMouse, stepX, stepY)
  local nextMouse = {
    x = currentMouse.x + stepX,
    y = currentMouse.y + stepY,
  }
  m.moveMouse(
    currentMouse.x,
    currentMouse.y,
    nextMouse.x,
    nextMouse.y,
    m.config.durationInMillis
  )
  return nextMouse
end

-- Move the mouse
m.moveMouse = function(x1,y1,x2,y2,sleepInMillis)
  local xdiff = x2 - x1
  local ydiff = y2 - y1
  local loop = math.floor( math.sqrt((xdiff*xdiff)+(ydiff*ydiff)) )
  local xinc = xdiff / loop
  local yinc = ydiff / loop
  sleepInMillis = math.floor((sleepInMillis * 1000) / loop)
  for i=1,loop do
  x1 = x1 + xinc
  y1 = y1 + yinc
  hs.mouse.absolutePosition({x = math.floor(x1), y = math.floor(y1)})
  hs.timer.usleep(sleepInMillis)
  end
  hs.mouse.absolutePosition({x = math.floor(x2), y = math.floor(y2)})
end


-- Start the jiggler module
m.start = function()
  local persistedState = hs.settings.get(m.config.isActiveKey)
  if persistedState ~= nil then
    isActive = persistedState
  end
  m.setState(isActive)
  m.toggle(true)
end


-- Add triggers
-----------------------------------------------
m.triggers = {}
m.triggers["Jiggler Toggle"] = m.toggle

----------------------------------------------------------------------------
return m

