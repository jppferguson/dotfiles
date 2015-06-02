
-----------------------------------------------
-- Default Settings
-----------------------------------------------

-- Set the default animation duration
local animationDuration = .2
hs.window.animationDuration = animationDuration


-----------------------------------------------
-- Resize currently focused window
-----------------------------------------------

function windowResize(w,h,x,y)
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x + (max.w * x)
  f.y = max.y + (max.h * y)
  f.w = max.w * w
  f.h = max.h * h
  win:setFrame(f)
end


-----------------------------------------------
-- Center currently focused window
-----------------------------------------------

function windowCenter()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local size = win:size()
  local max = screen:frame()

  f.x = 0 + (max.w / 2) - (size.w / 2)
  f.y = 0 + (max.h / 2) - (size.h / 2)
  win:setFrame(f)
end


-----------------------------------------------
-- Increment resize currently focused window
-----------------------------------------------

function windowIncrement(increment,increase)

  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  if not increase then increment = 0 - increment end

  f.x = f.x - (increment / 2)
  f.y = f.y - (increment / 2)
  f.w = f.w + increment
  f.h = f.h + increment

  -- make sure we dont go off the screen
  if f.x < 0 then f.x = 0 end

  win:setFrame(f,0)
end



-----------------------------------------------
-- Toggle fullscreen on the current window
-----------------------------------------------

function windowToggleFullscreen()
    local frontMostWindow = hs.window.focusedWindow()
    -- if not frontMostWindow then return exitModalHotkey(hotkey) end
    frontMostWindow:toggleFullScreen()
    -- exitModalHotkey(hotkey)
end




-----------------------------------------------
-- Move current window to another screen
-----------------------------------------------

function windowMoveToScreen(screen)
  local win = hs.window.focusedWindow()
  local screens = 0
  for _ in pairs(hs.screen.allScreens()) do screens = screens + 1 end
  hs.window.animationDuration = 0

  if screens >= 2 then
    if screen == 'prev' then
      local prevScreen = win:screen():previous()
      win:moveToScreen(prevScreen)
      notify("Previous Monitor")
    elseif screen == 'next' then
      local nextScreen = win:screen():next()
      win:moveToScreen(nextScreen)
      notify("Next Monitor")
    end
  else
    notify("There's only one monitor...")
  end

  -- reset animation duration
  hs.window.animationDuration = animationDuration

end
