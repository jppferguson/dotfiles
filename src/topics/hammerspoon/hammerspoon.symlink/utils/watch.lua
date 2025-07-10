
-- Path watching
-----------------------------------------------

local watch = {}

function watch.reloadConfig(files)
  print("=======reload caused by change by:")
  print (hs.inspect.inspect(files))
  -- hs.reload()
end


function watch.configPath(configPath)
  hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/" .. configPath, watch.reloadConfig):start()
end

----------------------------------------------------------------------------
return watch
