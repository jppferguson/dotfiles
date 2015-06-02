-----------------------------------------------
-- Notifications
-----------------------------------------------


function notify(message, useNotificationCenter, subtitle, infoText, callback, duration)

  local useNotificationCenter = useNotificationCenter == nil and true or useNotificationCenter
  local autoWithdraw = autoWithdraw == nil and true or useNotificationCenter
  local subtitle = subtitle or nil
  local infoText = infoText or nil
  local callback = callback or function() end
  local duration = duration or 1

  if useNotificationCenter then
    local notification = hs.notify.new(callback)
    notification:title(message)
    -- notification:subtitle(subtitle) -- API call not working...
    notification:informativeText(infoText)
    notification:send()
  else
    hs.alert(message, duration)
  end

end
