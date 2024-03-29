
-- Automatically move applications to the right screen:
-- Either on launch, or on connection of external screens.
-----------------------------------------------
local m = {}

local hotkey = require "hs.hotkey"
local alert = require "hs.alert"
local isActive = true

m.config = {
  isActiveKey = 'jspoon_app_screens',
  applications = {
    Code = "0,0",
    Simulator = 'Built%-in',
    Slack = '-1,0',
    Spotify = "Built%-in",
  },
  message = {
    enabled = 'App Screens Enabled',
    disabled = 'App Screens Disabled',
  },
}

m.handleMovingWindows = function(appName, app)
  local screens = hs.screen.allScreens()
  if isActive == false then
    return
  end

  for appKey, appScreen in pairs(m.config.applications) do
    if appName == appKey then
      local appMainWindow = app:mainWindow()
      appMainWindow:maximize()
      local screen = hs.screen(appScreen)
      if screen then
        appMainWindow:moveToScreen(screen)
      end
    end
  end
end

-- Watch applications
m.appWatcher = hs.application.watcher.new(function(appName, appEvent, app)
  if appEvent == hs.application.watcher.launched then
    m.handleMovingWindows(appName, app)
  end
end)

-- Reset positions
m.resetAppPositions = function()
  for appName in pairs(m.config.applications) do
    local app = hs.application.find(appName)
    if app.isRunning then
      m.handleMovingWindows(appName, app)
    end
  end
end

-- Watch screens
m.screenWatcher = hs.screen.watcher.new(m.resetAppPositions)

-- Set the autohide state
m.setState = function(state)
  local stateString = state and 'enabled' or 'disabled'
  alert.show(m.config.message[stateString])
  -- save the state
  isActive = state
  -- Persist the state across sessions
  hs.settings.set(m.config.isActiveKey, state)
end

-- Toggle the state
m.toggle = function()
  m.setState(not isActive)
end

-- Start the module
m.start = function()
  m.appWatcher:start()
  m.screenWatcher:start()
  m.setState(isActive)
end

-- Add triggers
-----------------------------------------------
m.triggers = {}
m.triggers["Reset App Locations"] = m.resetAppPositions

----------------------------------------------------------------------------
return m