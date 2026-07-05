-- Menubar Manager
--   Consolidates menubar items into a single dropdown on laptop-only screens.
--   Expands back to individual icons when an external display is connected.
-----------------------------------------------
local m = {}

m.config = {
  -- Modules to manage. Only modules present in jspoon.loadedModules are included.
  menubarModules = {
    { name = 'system.caffeine',  label = 'Caffeine' },
    { name = 'system.childlock', label = 'Child Lock' },
  },
  icon = {
    on = "assets/icons/caffeine/on.pdf",
    off = "assets/icons/caffeine/off.pdf",
  },
}

local consolidated = false
local unifiedMenubar = nil
local screenWatcher = nil

-- Determine if we're on the laptop screen only (no external display).
-- Returns false in clamshell mode (1 external screen, no built-in).
local function isLaptopOnly()
  local screens = hs.screen.allScreens()
  if #screens ~= 1 then return false end
  return hs.screen.find("Built%-in") ~= nil
end

-- Get the list of managed modules that are actually loaded.
local function getActiveModules()
  local active = {}
  for _, entry in ipairs(m.config.menubarModules) do
    local mod = jspoon.loadedModules[entry.name]
    if mod and mod.menubar then
      active[#active + 1] = {
        entry = entry,
        mod = mod,
      }
    end
  end
  return active
end

-- Read the current toggle state for a module.
local function getToggleState(entry, mod)
  if entry.name == 'system.caffeine' then
    return hs.caffeinate.get("displayIdle")
  elseif entry.name == 'system.childlock' then
    return mod.enabled
  elseif entry.name == 'system.nightshift' then
    return mod.enabled
  end
  return false
end

-- Get the caffeine state for the unified icon.
local function isCaffeinated()
  return hs.caffeinate.get("displayIdle")
end

-- Update the unified menubar icon to reflect caffeine state.
local function updateIcon()
  if not unifiedMenubar then return end
  local stateKey = isCaffeinated() and 'on' or 'off'
  unifiedMenubar:setIcon(m.config.icon[stateKey])
end

-- Build the consolidated menu dynamically.
local function buildMenu()
  local items = {}
  local activeModules = getActiveModules()

  for _, am in ipairs(activeModules) do
    local entry = am.entry
    local mod = am.mod
    local state = getToggleState(entry, mod)

    items[#items + 1] = {
      title = entry.label,
      checked = state,
      fn = function()
        if mod.toggleState then
          mod.toggleState()
        elseif mod.handleClick then
          mod.handleClick()
        end
        updateIcon()
      end,
    }
  end

  items[#items + 1] = { title = '-' }
  items[#items + 1] = {
    title = 'Reload Config',
    fn = function() hs.reload() end,
  }

  return items
end

-- Consolidate: hide individual menubars, show unified one.
local function consolidate()
  if consolidated then return end
  consolidated = true
  m.log.i('Consolidating menubar items')

  local activeModules = getActiveModules()
  for _, am in ipairs(activeModules) do
    am.mod.menubar:removeFromMenuBar()
  end

  if not unifiedMenubar then
    unifiedMenubar = hs.menubar.new(true, 'menubar-manager')
    unifiedMenubar:setTooltip('Hammerspoon')
  else
    unifiedMenubar:returnToMenuBar()
  end

  updateIcon()
  unifiedMenubar:setMenu(buildMenu)
end

-- Expand: show individual menubars, hide unified one.
local function expand()
  if not consolidated then return end
  consolidated = false
  m.log.i('Expanding menubar items')

  if unifiedMenubar then
    unifiedMenubar:removeFromMenuBar()
  end

  local activeModules = getActiveModules()
  for _, am in ipairs(activeModules) do
    am.mod.menubar:returnToMenuBar()
  end
end

-- Check screen state and consolidate/expand accordingly.
local function checkScreens()
  if isLaptopOnly() then
    consolidate()
  else
    expand()
  end
end

-- Screen change handler with a delay to let macOS settle.
local function onScreenChange()
  hs.timer.doAfter(1, checkScreens)
end

function m.start()
  screenWatcher = hs.screen.watcher.new(onScreenChange)
  screenWatcher:start()

  -- Defer initial check so all other modules have started first.
  hs.timer.doAfter(0.5, checkScreens)
end

function m.stop()
  if screenWatcher then
    screenWatcher:stop()
    screenWatcher = nil
  end

  -- Restore individual menubars if we were consolidated.
  if consolidated then
    expand()
  end

  if unifiedMenubar then
    unifiedMenubar:delete()
    unifiedMenubar = nil
  end
end

return m
