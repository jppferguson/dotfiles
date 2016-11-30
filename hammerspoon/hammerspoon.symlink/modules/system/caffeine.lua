-- Caffeine
--   Keep computer awake
-----------------------------------------------
local caffeine = {}
local alert = jspoon.utils.alert
local log = jspoon.log

caffeine.config = {
  isActiveDir = hs.fs.temporaryDirectory() .. "caffeineIsAActive/",
  message = {
    caffinated = 'Coffee is good',
    decaffinated = 'Sleep is good'
  },
  assets = {
    iconOn = "assets/images/caffeine-on.pdf",
    iconOff = "assets/images/caffeine-off.pdf",
  }
}

caffeine.menubar = hs.menubar.new()

function caffeine.setPersistantState(state)
  if(state) then
    hs.fs.mkdir(caffeine.config.isActiveDir)
  else
    hs.fs.rmdir(caffeine.config.isActiveDir)
  end
end

function caffeine.getPersistantState()
  return (hs.fs.attributes(caffeine.config.isActiveDir) ~= nil)
end

function caffeine.setDisplay(state)
    local result
    if state then
        result = caffeine.menubar:setIcon(caffeine.config.assets.iconOn)
        caffeine.log.i(caffeine.config.message.caffinated)
        alert.simple(caffeine.config.message.caffinated)
    else
        result = caffeine.menubar:setIcon(caffeine.config.assets.iconOff)
        caffeine.log.i(caffeine.config.message.decaffinated)
        alert.simple(caffeine.config.message.decaffinated)
    end
    hs.caffeinate.set("displayIdle", state)
    caffeine.setPersistantState(state)
end

function caffeine.handleClick()
    caffeine.setDisplay(hs.caffeinate.toggle("displayIdle"))
end


function caffeine.start()
  if caffeine.menubar then
      caffeine.menubar:setClickCallback(caffeine.handleClick)
      caffeine.setDisplay(caffeine.getPersistantState())
      caffeine.log.i(caffeine.config)
  end
end


-- Add triggers
-----------------------------------------------
caffeine.triggers = {}
caffeine.triggers["Caffeine Toggle"] = caffeine.handleClick


----------------------------------------------------------------------------
return caffeine
