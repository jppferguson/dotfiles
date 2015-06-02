
-----------------------------------------------
-- Reload config on write
-----------------------------------------------

function reloadConfig(files)
  hs.reload()
end

hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()



-----------------------------------------------
-- Show the date and time
-----------------------------------------------

function showDateAndTime()
    notify(os.date("It's %R on %B %e, %G"))
end
