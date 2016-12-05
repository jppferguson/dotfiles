-- Caffeine
--   Keep computer awake
-----------------------------------------------
local caffeine = {}
local alert = jspoon.utils.alert

caffeine.config = {
  isActiveKey = 'jspoon_caffeine',
  message = {
    caffinated = 'Coffee is good',
    decaffinated = 'Sleep is good'
  },
  assets = {
    caffinated = "assets/icons/caffeine/on.pdf",
    decaffinated = "assets/icons/caffeine/off.pdf",
  }
}

caffeine.menubar = hs.menubar.new()

function caffeine.getStateKey(state) return state and 'caffinated' or 'decaffinated' end

function caffeine.setState(state)
    local stateKey = caffeine.getStateKey(state)
    -- Set menubar icon
    caffeine.menubar:setIcon(caffeine.config.assets[stateKey])
    -- Log state to console
    caffeine.log.i('Setting to ' .. stateKey)
    -- Alert message to user
    alert.simple(caffeine.config.message[stateKey])
    -- Set the caffeinate state
    hs.caffeinate.set("displayIdle", state)
    -- Persist the state across sessions
    hs.settings.set(caffeine.config.isActiveKey, state)
end

function caffeine.toggleState()
    caffeine.setState(hs.caffeinate.toggle("displayIdle"))
end

function caffeine.handleClick()
    caffeine.toggleState()
end

function caffeine.start()
  -- Get the persistant state
  local persistedState = hs.settings.get(caffeine.config.isActiveKey)
  if caffeine.menubar then
    caffeine.log.i('Persisted state was ' .. caffeine.getStateKey(persistedState))
    -- Set the click handler
    caffeine.menubar:setClickCallback(caffeine.handleClick)
    -- Set the state
    caffeine.setState(persistedState)
  end
end


-- Add triggers
-----------------------------------------------
caffeine.triggers = {}
caffeine.triggers["Caffeine Toggle"] = caffeine.handleClick


----------------------------------------------------------------------------
return caffeine
