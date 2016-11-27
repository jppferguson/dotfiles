
-- Wifi
--   Notify on wifi changes
-----------------------------------------------
local wifi = {}
local alert = jspoon.utils.alert

-- keep track of the previously connected network
local lastNetwork = hs.wifi.currentNetwork()

-- callback called when wifi network changes
local function ssidChangedCallback()
    local newNetwork = hs.wifi.currentNetwork()

    -- send notification if we're on a different network than we were before
    if lastNetwork ~= newNetwork then
      hs.notify.new({
        title = 'Wi-Fi Status',
        subTitle = newNetwork and 'Network:' or 'Disconnected',
        informativeText = newNetwork,
        contentImage = wifi.cfg.icon,
        autoWithdraw = true,
        hasActionButton = false,
      }):send()

      lastNetwork = newNetwork
    end
end

function wifi.start()
  wifi.watcher = hs.wifi.watcher.new(ssidChangedCallback)
  wifi.watcher:start()
end

function wifi.stop()
  wifi.watcher:stop()
  wifi.watcher = nil
end


function wifi.status()
  output = io.popen("networksetup -getairportpower en0", "r")
  result = output:read()
  return result:find(": On") and "on" or "off"
end

function wifi.toggle()
  if wifi.status() == "on" then
    alert.simple("Wi-Fi: Off")
    os.execute("networksetup -setairportpower en0 off")
  else
    alert.simple("Wi-Fi: On")
    os.execute("networksetup -setairportpower en0 on")
  end
end


-- Add triggers
-----------------------------------------------
wifi.triggers = {}
wifi.triggers["WiFi Status"] = wifi.status
wifi.triggers["WiFi Toggle"] = wifi.toggle

----------------------------------------------------------------------------
return wifi
