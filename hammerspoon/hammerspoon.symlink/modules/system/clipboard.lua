-- Clipboard management
--   Manage clipboard history
--     Mainly based on dbmrq's clipboard.lua
--     (https://github.com/dbmrq/dotfiles/blob/master/home/.hammerspoon/clipboard.lua)
-----------------------------------------------
local clipboard = {}
local pasteboard = require("hs.pasteboard")
local pasteboardCounter = 0
local settings = require("hs.settings")

clipboard.config = {
  menubar = {
    historySize = 30,
    title = "✂",
    tooltip = "Clipboard",
    width = 40,
  },
  clipboardKey = 'jspoon_clipboard',
}

clipboard.menubar = hs.menubar.new()
clipboard.lastChange = pasteboard.changeCount()
clipboard.history = settings.get(clipboard.config.clipboardKey) or {}

clipboard.clearAll = function()
    pasteboard.clearContents()
    clipboard.history = {}
    settings.set(clipboard.config.clipboardKey, clipboard.history)
    pasteboardCounter = pasteboard.changeCount()
end

clipboard.clearLastItem = function()
    table.remove(clipboard.history, #clipboard.history)
    settings.set(clipboard.config.clipboardKey, clipboard.history)
    pasteboardCounter = pasteboard.changeCount()
end

clipboard.addToClipboard = function(item)
    -- limit quantity of entries
    while (#clipboard.history >= clipboard.config.menubar.historySize) do
        table.remove(clipboard.history, 1)
    end
    table.insert(clipboard.history, item)
    settings.set(clipboard.config.clipboardKey, clipboard.history)
end

clipboard.copyOrPaste = function(string,key)
    if (key.alt == true) then
      hs.eventtap.keyStrokes(string)
    else
      pasteboard.setContents(string)
      last_change = pasteboard.changeCount()
    end
end

clipboard.populateMenu = function(key)
    menuData = {}
    if (#clipboard.history == 0) then
        table.insert(menuData, {title="None", disabled = true})
    else
        for k, v in pairs(clipboard.history) do
            if string.len(v) > clipboard.config.menubar.width then
                table.insert(menuData, 1,
                    {title=string.sub(v, 0, clipboard.config.menubar.width).."…",
                    fn = function() clipboard.copyOrPaste(v, key) end })
            else
                table.insert(menuData, 1,
                    {title=v, fn = function() clipboard.copyOrPaste(v, key) end })
            end
        end
    end
    table.insert(menuData, {title="-"})
    table.insert(menuData,
        {title="Clear All", fn = function() clipboard.clearAll() end })
    return menuData
end

clipboard.storeCopy = function()
    pasteboardCounter = pasteboard.changeCount()
    if pasteboardCounter > clipboard.lastChange then
        currentContents = pasteboard.getContents()
        clipboard.addToClipboard(currentContents)
        clipboard.lastChange = pasteboardCounter
    end
end

clipboard.start = function()
  local copy
  clipboard.menubar:setTooltip(clipboard.config.menubar.tooltip)
  clipboard.menubar:setTitle(clipboard.config.menubar.title)
  clipboard.menubar:setMenu(clipboard.populateMenu)

  copy = hs.hotkey.bind({"cmd"}, "c", function()
      copy:disable()
      hs.eventtap.keyStroke({"cmd"}, "c")
      copy:enable()
      hs.timer.doAfter(1, clipboard.storeCopy)
  end)

end


-- Add triggers
-----------------------------------------------
clipboard.triggers = {}


----------------------------------------------------------------------------
return clipboard
