
-- Headphones
--   Mute when headphones unplugged
-----------------------------------------------
local headphones = {}
local alert = jspoon.utils.alert

-- Mute on jack in/out
function headphones.audioCallback(uid, eventName, eventScope, channelIdx)
  if eventName == 'jack' then
    alert.simple("Headphone jack changed, muting.")
    hs.audiodevice.defaultOutputDevice():setVolume(0)
  end
end

function headphones.start()
  local defaultDevice = hs.audiodevice.defaultOutputDevice()
  defaultDevice:watcherCallback(headphones.audioCallback);
  defaultDevice:watcherStart();
end

----------------------------------------------------------------------------
return headphones
