
-- Airpods
--   "Fix" shity Airpods bug by not automatically 
--   setting a bluetooth audio input device
--   From: <http://ssrubin.com/posts/fixing-macos-bluetooth-headphone-audio-quality-issues-with-hammerspoon.html>
-----------------------------------------------
local m = {}
local alert = jspoon.utils.alert

lastSetDeviceTime = os.time()
lastInputDevice = nil


m.config = {
  message = "There, fixed the shity AirPods bug. You're welcome."
}

-- Mute on headphone jack plugged/unplugged
m.audioCallback = function(arg)
  if arg == 'dev#' then
      lastSetDeviceTime = os.time()
  elseif arg == 'dIn ' and os.time() - lastSetDeviceTime < 2 then
      inputDevice = hs.audiodevice.defaultInputDevice()
      if inputDevice:transportType() == 'Bluetooth' then
          internalMic = lastInputDevice or hs.audiodevice.findInputByName('Built-in Microphone')
          internalMic:setDefaultInputDevice()
          alert.simple(m.config.message, 1)
      end
  end
  if hs.audiodevice.defaultInputDevice():transportType() ~= 'Bluetooth' then
      lastInputDevice = hs.audiodevice.defaultInputDevice()
  end
end

m.start = function()
  hs.audiodevice.watcher.setCallback(m.audioCallback)
  hs.audiodevice.watcher.start()
end

----------------------------------------------------------------------------
return m
