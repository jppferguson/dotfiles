
-- Display keyboard shortcuts
-----------------------------------------------
local shortcuts = {}
shortcuts.helpstr = ''

shortcuts.config = {
  helpCharPad = 30,
  fadeOut = .5,
  fadeIn = .3,
}

shortcuts.keyStrings = {
  ["Left"] = "←",
  ["Right"] = "→",
  ["Up"] = "↑",
  ["Down"] = "↓",
  ["cmd"] = "⌘",
  ["alt"] = "⌥",
  ["option"] = "⌥",
  ["opt"] = "⌥",
  ["ctrl"] = "⌃",
  ["shift"] = "⇧"
}

--- Pads str to length len with char from right
function lpad(str, len, char)
    if char == nil then char = ' ' end
    return str .. string.rep(char, len - #str)
end

function shortcuts.close()
  shortcuts.helpOverlayBG:hide(shortcuts.config.fadeOut)
  shortcuts.helpOverlayX:hide(shortcuts.config.fadeOut/2)
  shortcuts.helpOverlay:hide(shortcuts.config.fadeOut/2)
end

function shortcuts.calcFontSize(windowHeight, min, max)
  local size = windowHeight / jspoon.fn.tablelength(jspoon.utils.keys.shortcuts) * .45
  if(size < min) then size = min or 10 end
  if(size > max) then size = max or 30 end
  return size
end

function shortcuts.calcWindowWidth(fontSize)
  return fontSize * shortcuts.config.helpCharPad * 1.1
end

function shortcuts.makeShortcutReplacements(str)
  if(shortcuts.keyStrings[str]) then
    str = shortcuts.keyStrings[str]
  elseif(jspoon.utils.keys.modifiers[str]) then
    str = jspoon.utils.keys.modifiers[str]
  end
  if (type(str) == "table") then
    local newStr1 = ""
    local newStr2
    for key, value in pairs(str) do
      if (type(value) == "string") then
        newStr2 = shortcuts.makeShortcutReplacements(value)
        newStr1 = newStr1 .. newStr2
      end
    end
    str = newStr1
  end
  return str
end

function shortcuts.createShortcutString(keysTable)
  local keys = {}
  for key, value in pairs(keysTable) do
    keys[key] = shortcuts.makeShortcutReplacements(value)
  end
  return table.concat(keys, " + ")
end

function shortcuts.showHelpOverlay(message)
  if shortcuts.helpOverlay then
    shortcuts.helpOverlayX:delete()
    shortcuts.helpOverlayBG:delete()
    shortcuts.helpOverlay:delete()
    if shortcuts.helpOverlayTimer then
      shortcuts.helpOverlayTimer:stop()
    end
  end

  local scr = hs.screen.primaryScreen():currentMode()
  local windowHeight = scr.h - 400
  local fontSize = shortcuts.calcFontSize(windowHeight, 12, 24)
  local windowWidth = shortcuts.calcWindowWidth(fontSize)
  local ov = {
    p = 30,
    w = windowWidth,
    h = windowHeight,
    x = scr.w / 2 - windowWidth / 2,
    y = scr.h / 2 - windowHeight / 2 - 50,
  }

  shortcuts.helpOverlayX = hs.drawing.text(hs.geometry.rect(ov.x + ov.w, ov.y, 50, 50), "×")
  shortcuts.helpOverlayBG = hs.drawing.rectangle(hs.geometry.rect(ov.x, ov.y, ov.w + ov.p * 2, ov.h + ov.p * 2))
  shortcuts.helpOverlay = hs.drawing.text(hs.geometry.rect(ov.x + ov.p, ov.y + ov.p, ov.w, ov.h), message)
  local font = hs.styledtext.convertFont({
    name = 'Fira Code',
    size = fontSize
  }, 0)
  local textStyle = {
    font = font,
    paragraphStyle = {
      alignment = "left",
      lineSpacing = fontSize * .6,
      tabStops = {{
        location = fontSize * .1 * 180,
        tabStopType = 'right'
      },
      {
        location = fontSize * .1 * 245,
        tabStopType = 'right'
      }}
    },
    shadow = {
      offset = {h = -1, w = 1},
      blurRadius = 3
    }
  }
  shortcuts.helpOverlayBG:setFillColor({["red"]=0,["blue"]=0,["green"]=0,["alpha"]=0.8}):setFill(true):show()
  shortcuts.helpOverlay:setStyledText(hs.styledtext.ansi(message, textStyle))
  shortcuts.helpOverlayX:setTextSize(50)
  shortcuts.helpOverlay:bringToFront(true)
  shortcuts.helpOverlay:show(shortcuts.config.fadeIn)
  shortcuts.helpOverlayX:bringToFront(true):show(shortcuts.config.fadeIn)
  shortcuts.helpOverlayX:setClickCallback(shortcuts.close)
  shortcuts.helpOverlay:setClickCallback(shortcuts.close)
end

function shortcuts.updateHelpString()
  local allShortcuts = {}
  local scTable = jspoon.utils.keys.shortcuts
  table.insert(allShortcuts, "\t KEYBOARD\tSHORTCUTS")
  for key, value in pairs(scTable) do
    local scTitle = key
    local scKeys = shortcuts.createShortcutString(value)
    table.insert(allShortcuts, string.format("\t%s\t%s", scTitle, scKeys ))
  end
  table.sort(allShortcuts)
  shortcuts.helpstr = table.concat(allShortcuts,'\n')
end


function shortcuts.display()
  shortcuts.updateHelpString()
  shortcuts.showHelpOverlay(shortcuts.helpstr)
end

-- Add triggers
-----------------------------------------------
shortcuts.triggers = {}
shortcuts.triggers["Keyboard Help"] = shortcuts.display

----------------------------------------------------------------------------
return shortcuts
