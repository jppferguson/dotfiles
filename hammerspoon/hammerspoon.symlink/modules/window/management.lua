
-- Window management
-----------------------------------------------
local window = {}
local hswindow = hs.window
local alert = jspoon.utils.alert.simple
local isRectsApproxMatch = jspoon.utils.misc.isRectsApproxMatch
local lastWindowLocation = {
  center = {},
  max = {},
}

-----------------------------------------------
-- Default Settings
-----------------------------------------------
window.config = {
  animationDuration = .2,
  grid = {
    MARGINX = 0,
    MARGINY = 0,
    GRIDWIDTH = 12,
    GRIDHEIGHT = 4,
  }
}


-----------------------------------------------
-- Resize currently focused window
-----------------------------------------------

function window.resize(w,h,x,y)
  local win = hswindow.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  if not win then
    window.alertCannotManipulateWindow()
    return
  end

  f.x = max.x + (max.w * x)
  f.y = max.y + (max.h * y)
  f.w = max.w * w
  f.h = max.h * h
  win:setFrame(f)
end


-----------------------------------------------
-- Toggle align center currently focused window
-----------------------------------------------

function window.toggleCenter()
  local win = hswindow.focusedWindow()
  local winFrame = win:frame()
  local winThis = win:id()
  local screen = win:screen()
  local size = win:size()
  local max = screen:frame()
  local centerFrame = win:frame()

  if not win then
    window.alertCannotManipulateWindow()
    return
  end

  centerFrame.x = 0 + (max.w / 2) - (size.w / 2)
  centerFrame.y = 0 + (max.h / 2) - (size.h / 2)

  if isRectsApproxMatch(winFrame, centerFrame) then
    if lastWindowLocation.center[winThis] then
      win:setFrame(lastWindowLocation.center[winThis])
      lastWindowLocation.center[winThis] = nil
    end
  else
    lastWindowLocation.center[winThis] = winFrame
    win:setFrame(centerFrame)
  end
end


-----------------------------------------------
-- Increment resize currently focused window
-----------------------------------------------

function window.increment(increment, increase)

  local win = hswindow.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  if not win then
    window.alertCannotManipulateWindow()
    return
  end

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

function window.toggleFullscreen()
  local win = hswindow.focusedWindow()

  if not win then
    window.alertCannotManipulateWindow()
    return
  end

  win:toggleFullScreen()
end


-----------------------------------------------
-- Toggle maximize on the current window
-----------------------------------------------

function window.toggleMaximize()
  local win = hswindow.focusedWindow()
  local winFrame = win:frame()
  local winThis = win:id()
  local screenFrame = win:screen():frame()

  if not win then
    window.alertCannotManipulateWindow()
    return
  end

  if isRectsApproxMatch(winFrame, screenFrame) then
    if lastWindowLocation.max[winThis] then
      win:setFrame(lastWindowLocation.max[winThis])
      lastWindowLocation.max[winThis] = nil
    end
  else
    lastWindowLocation.max[winThis] = winFrame
    win:maximize()
  end
end


-----------------------------------------------
-- Move current window to another screen
-----------------------------------------------

function window.moveToScreen(screen)
  local win = hswindow.focusedWindow()
  local screens = 0
  for _ in pairs(hs.screen.allScreens()) do screens = screens + 1 end
  hswindow.animationDuration = 0

  if not win then
    window.alertCannotManipulateWindow()
    return
  end

  if screens >= 2 then
    if screen == 'prev' then
      local prevScreen = win:screen():previous()
      win:moveToScreen(prevScreen)
      alert("Previous Monitor")
    elseif screen == 'next' then
      local nextScreen = win:screen():next()
      win:moveToScreen(nextScreen)
      alert("Next Monitor")
    end
  else
    alert("There's only one monitor...")
  end

  -- reset animation duration
  hswindow.animationDuration = animationDuration

end

-----------------------------------------------
-- Push window
-----------------------------------------------

function window.pushWindow(direction)
  local win = hs.window.focusedWindow()
  local winGrid = hs.grid.get(win)
  local result

  if not win then
    window.alertCannotManipulateWindow()
    return
  end

  if(direction == "up") then
    if(winGrid.y == 0) then
      -- make window shorter if we are at the top
      result = hs.grid.resizeWindowShorter(win)
    else
      result = hs.grid.pushWindowUp(win)
    end
  elseif(direction == "right") then
    if(winGrid.x == (window.config.grid.GRIDWIDTH - winGrid.w)) then
      -- make window thinner if we are at the right
      result = hs.grid.resizeWindowThinner(win)
    end
    result = hs.grid.pushWindowRight(win)
  elseif(direction == "down") then
    if(winGrid.y == (window.config.grid.GRIDHEIGHT - winGrid.h)) then
      -- make window shorter if we are at the top
      result = hs.grid.resizeWindowShorter(win)
    end
    result = hs.grid.pushWindowDown(win)
  elseif(direction == "left") then
    if(winGrid.x == 0) then
      -- make window thinner if we are at the left
      result = hs.grid.resizeWindowThinner(win)
    else
      result = hs.grid.pushWindowLeft(win)
    end
  end
end

-----------------------------------------------
-- Check can move window
-----------------------------------------------

function window.alertCannotManipulateWindow()
  alert.show("Can't move window")
end


-----------------------------------------------
-- Start
-----------------------------------------------
function window.start()
  -- Set the default animation duration
  hswindow.animationDuration = window.config.animationDuration

  hs.grid.MARGINX    = window.config.grid.MARGINX
  hs.grid.MARGINY    = window.config.grid.MARGINY
  hs.grid.GRIDWIDTH  = window.config.grid.GRIDWIDTH
  hs.grid.GRIDHEIGHT = window.config.grid.GRIDHEIGHT

end


-- Add triggers
-----------------------------------------------
window.triggers = {}

-- Center current window
window.triggers["Window Toggle Center"] = window.toggleCenter

-- Resize current window to maximise or fullscreen
window.triggers["Window Toggle Maximise"] = window.toggleMaximize
window.triggers["Window Toggle Fullscreen"] = window.toggleFullscreen

-- Resize current window to half of the screen using arrow keys
window.triggers["Window Half Left"]   = function() window.resize(.5, 1, 0, 0) end
window.triggers["Window Half Right"]  = function() window.resize(.5, 1,.5, 0) end
window.triggers["Window Half Top"]    = function() window.resize( 1,.5, 0, 0) end
window.triggers["Window Half Bottom"] = function() window.resize( 1,.5, 0,.5) end

-- Move current window to quarter of the screen using u,i,j,k
window.triggers["Window Quarter Top Left"]     = function() window.resize(.5,.5, 0, 0) end
window.triggers["Window Quarter Top Right"]    = function() window.resize(.5,.5,.5, 0) end
window.triggers["Window Quarter Bottom Right"] = function() window.resize(.5,.5, 0,.5) end
window.triggers["Window Quarter Bottom Left"]  = function() window.resize(.5,.5,.5,.5) end

-- Make current window larger/smaller
window.triggers["Window Larger"]  = function() window.increment(20, true) end
window.triggers["Window Smaller"] = function() window.increment(20, false) end

-- Move current window to next/prev display
window.triggers["Window Previous Screen"] = function() window.moveToScreen('prev') end
window.triggers["Window Next Screen"]     = function() window.moveToScreen('next') end

-- Shift window on grid
window.triggers["Window Push Left"]  = function() window.pushWindow('left') end
window.triggers["Window Push Right"] = function() window.pushWindow('right') end
window.triggers["Window Push Up"]    = function() window.pushWindow('up') end
window.triggers["Window Push Down"]  = function() window.pushWindow('down') end

-- Resize window on grid
window.triggers["Window Resize Thinner"] = function() hs.grid.resizeWindowThinner(hs.window.focusedWindow()) end
window.triggers["Window Resize Shorter"] = function() hs.grid.resizeWindowShorter(hs.window.focusedWindow()) end
window.triggers["Window Resize Taller"]  = function() hs.grid.resizeWindowTaller(hs.window.focusedWindow()) end
window.triggers["Window Resize Wider"]   = function() hs.grid.resizeWindowWider(hs.window.focusedWindow()) end

-- Interactive grid
window.triggers["Window Show Grid"] = function() hs.grid.show(nil, true) end
window.triggers["Window Hide Grid"] = hs.grid.hide


-- TODO: Move current window to next/prev third
-- TODO: Undo/redo

----------------------------------------------------------------------------
return window
