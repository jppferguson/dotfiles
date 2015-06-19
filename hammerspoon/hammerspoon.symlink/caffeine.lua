
local caffeine = hs.menubar.new()

-----------------------------------------------
-- Caffeine
-----------------------------------------------

function setCaffeineDisplay(state)
    local result
    if state then
        result = caffeine:setIcon("assets/images/caffeine-on.pdf")
    else
        result = caffeine:setIcon("assets/images/caffeine-off.pdf")
    end
end

function caffeineClicked()
    setCaffeineDisplay(hs.caffeinate.toggle("displayIdle"))
end

if caffeine then
    caffeine:setClickCallback(caffeineClicked)
    setCaffeineDisplay(hs.caffeinate.get("displayIdle"))
end
