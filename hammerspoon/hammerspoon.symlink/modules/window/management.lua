
-- Window management
-----------------------------------------------
local window = {}
local hswindow = hs.window
local alert = jspoon.utils.alert.simple

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
-- Default Settings
-----------------------------------------------


-----------------------------------------------
-- Resize currently focused window
-----------------------------------------------

function window.resize(w,h,x,y)
  local win = hswindow.focusedWindow()
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

function window.center()
  local win = hswindow.focusedWindow()
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

function window.increment(increment, increase)

  local win = hswindow.focusedWindow()
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

function window.toggleFullscreen()
    local frontMostWindow = hswindow.focusedWindow()
    -- if not frontMostWindow then return exitModalHotkey(hotkey) end
    frontMostWindow:toggleFullScreen()
    -- exitModalHotkey(hotkey)
end




-----------------------------------------------
-- Move current window to another screen
-----------------------------------------------

function window.moveToScreen(screen)
  local win = hswindow.focusedWindow()
  local screens = 0
  for _ in pairs(hs.screen.allScreens()) do screens = screens + 1 end
  hswindow.animationDuration = 0

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
window.triggers["Window Center"] = window.center

-- Resize current window to maximise or fullscreen
window.triggers["Window Maximise"] = function() window.resize( 1, 1, 0, 0) end
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
window.triggers["Window Push Left"]  = function() hs.grid.pushWindowLeft(hs.window.focusedWindow()) end
window.triggers["Window Push Right"] = function() hs.grid.pushWindowRight(hs.window.focusedWindow()) end
window.triggers["Window Push Up"]    = function() hs.grid.pushWindowUp(hs.window.focusedWindow()) end
window.triggers["Window Push Down"]  = function() hs.grid.pushWindowDown(hs.window.focusedWindow()) end

-- Resize window on grid
window.triggers["Window Resize Thinner"] = function() hs.grid.resizeWindowThinner(hs.window.focusedWindow()) end
window.triggers["Window Resize Shorter"] = function() hs.grid.resizeWindowShorter(hs.window.focusedWindow()) end
window.triggers["Window Resize Taller"]  = function() hs.grid.resizeWindowTaller(hs.window.focusedWindow()) end
window.triggers["Window Resize Wider"]   = function() hs.grid.resizeWindowWider(hs.window.focusedWindow()) end


-- TODO: Move current window to next/prev third
-- TODO: Undo/redo

----------------------------------------------------------------------------
return window
