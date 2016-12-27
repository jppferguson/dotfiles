
-- Wifi
--   Notify on wifi changes
-----------------------------------------------
local m = {}
local alert = require('hs.alert').show
local wifi = require('hs.wifi')

-- keep track of the previously connected network
local lastNetwork = wifi.currentNetwork()

-- callback called when wifi network changes
local function ssidChangedCallback()
    local newNetwork = wifi.currentNetwork()

    -- send notification if we're on a different network than we were before
    if lastNetwork ~= newNetwork then
      hs.notify.new({
        title = 'Wi-Fi Status',
        subTitle = newNetwork and 'Network:' or 'Disconnected',
        informativeText = newNetwork,
        contentImage = m.cfg.icon,
        autoWithdraw = true,
        hasActionButton = false,
      }):send()

      lastNetwork = newNetwork
    end
end

-- Get the wifi status
m.status = function()
  output = io.popen("networksetup -getairportpower en0", "r")
  result = output:read()
  return result:find(": On") and "on" or "off"
end

-- Toggle the wifi on and off
m.toggle = function()
  if m.status() == "on" then
    alert("Wi-Fi: Off")
    os.execute("networksetup -setairportpower en0 off")
  else
    alert("Wi-Fi: On")
    os.execute("networksetup -setairportpower en0 on")
  end
end

-- Start the module
m.start = function()
  m.watcher = wifi.watcher.new(ssidChangedCallback)
  m.watcher:start()
end

-- Stop the module
m.stop = function()
  m.watcher:stop()
  m.watcher = nil
end

-- Add triggers
-----------------------------------------------
m.triggers = {}
m.triggers["WiFi Toggle"] = m.toggle

----------------------------------------------------------------------------
return m
