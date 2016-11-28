
-- Display keyboard shortcuts
-----------------------------------------------
local shortcuts = {}
shortcuts.helpstr = ''

--- Pads str to length len with char from right
function lpad(str, len, char)
    if char == nil then char = ' ' end
    return str .. string.rep(char, len - #str)
end

function shortcuts.close()
  shortcuts.helpOverlay:hide(.2)
end

function shortcuts.showHelpOverlay(message)
  if shortcuts.helpOverlay then
    shortcuts.helpOverlay:delete()
    if shortcuts.helpOverlayTimer then
      shortcuts.helpOverlayTimer:stop()
    end
  end

  shortcuts.helpOverlay = hs.drawing.text(hs.geometry.rect(300, 200, 800, 800), message)
  local font = hs.styledtext.convertFont({
    name = 'Fira Code',
    size = 18
  }, 0)
  local textStyle = {
    font = font,
    paragraphStyle = {
      lineSpacing = 15,
    },
    shadow = {
      offset = {h = -1, w = 1},
      blurRadius = 3
    }
  }
  shortcuts.helpOverlay:setStyledText(hs.styledtext.ansi(message, textStyle))
  shortcuts.helpOverlay:bringToFront(true)
  shortcuts.helpOverlay:show(.2)
  shortcuts.helpOverlay:setClickCallback(shortcuts.close)
end

function shortcuts.updateHelpString()
  local allShortcuts = {}
  for key, value in pairs(jspoon.utils.keys.shortcuts) do
    local scTitle = key
    local scKeys = table.concat(value, " + ")
    table.insert(allShortcuts, string.format("%s      %s", lpad(scTitle, 40), scKeys))
  end
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
