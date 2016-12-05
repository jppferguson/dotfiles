-- Weather
--   Current conditions for your location
--   Largely based on <https://github.com/skamsie/hs-weather>
-------------------------------------------------------------

local weather = {}
local hammerDir = hs.fs.currentDir()
local iconsDir = (hammerDir .. '/assets/icons/weather/')
local urlBase = 'https://query.yahooapis.com/v1/public/yql?q='
local query = 'select item.title, item.condition from weather.forecast where \
               woeid in (select woeid from geo.places(1) where text="'

weather.config = {
  geolocation = false,
  location = "London, UK",
  refresh = 1800,
  units = "C"
}


-- https://developer.yahoo.com/weather/archive.html#codes
-- icons by RNS, Freepik, Vectors Market, Yannick at http://www.flaticon.com
weatherSymbols = {
  [0] = (iconsDir .. 'tornado.png'),      -- tornado
  [1] = (iconsDir .. 'storm.png'),        -- tropical storm
  [2] = (iconsDir .. 'tornado.png'),      -- hurricane
  [3] = (iconsDir .. 'storm-5.png'),      -- severe thunderstorms
  [4] = (iconsDir .. 'storm-4.png'),      -- thunderstorms
  [5] = (iconsDir .. 'sleet.png'),        -- mixed rain and snow
  [6] = (iconsDir .. 'sleet.png'),        -- mixed rain and sleet
  [7] = (iconsDir .. 'sleet.png'),        -- mixed snow and sleet
  [8] = (iconsDir .. 'drizzle.png'),      -- freezing drizzle
  [9] = (iconsDir .. 'drizzle.png'),      -- drizzle
  [10] = (iconsDir .. 'drizzle.png'),     -- freezing rain
  [11] = (iconsDir .. 'rain-1.png'),      -- showers
  [12] = (iconsDir .. 'rain-1.png'),      -- showers
  [13] = (iconsDir .. 'snowflake.png'),   -- snow flurries
  [14] = (iconsDir .. 'snowflake.png'),   -- light snow showers
  [15] = (iconsDir .. 'snowflake.png'),   -- blowing snow
  [16] = (iconsDir .. 'snowflake.png'),   -- snow
  [17] = (iconsDir .. 'hail.png'),        -- hail
  [18] = (iconsDir .. 'sleet.png'),       -- sleet
  [19] = (iconsDir .. 'haze.png'),        -- dust
  [20] = (iconsDir .. 'mist.png'),        -- foggy
  [21] = (iconsDir .. 'haze.png'),        -- haze
  [22] = (iconsDir .. 'mist.png'),        -- smoky
  [23] = (iconsDir .. 'wind-1.png'),      -- blustery
  [24] = (iconsDir .. 'windy-1.png'),     -- windy
  [25] = (iconsDir .. 'cold.png'),        -- cold
  [26] = (iconsDir .. 'clouds.png'),      -- cloudy
  [27] = (iconsDir .. 'night.png'),       -- mostly cloudy (night)
  [28] = (iconsDir .. 'cloudy.png'),      -- mostly cloudy (day)
  [29] = (iconsDir .. 'cloudy-4.png'),    -- partly cloudy (night)
  [30] = (iconsDir .. 'cloudy-5.png'),    -- partly cloudy (day)
  [31] = (iconsDir .. 'moon-2.png'),      -- clear (night)
  [32] = (iconsDir .. 'sun-1.png'),       -- sunny
  [33] = (iconsDir .. 'night-2.png'),     -- fair (night)
  [34] = (iconsDir .. 'cloudy-1.png'),    -- fair (day)
  [35] = (iconsDir .. 'hail.png'),        -- mixed rain and hail
  [36] = (iconsDir .. 'temperature.png'), -- hot
  [37] = (iconsDir .. 'storm-4.png'),     -- isolated thunderstorms
  [38] = (iconsDir .. 'storm-2.png'),     -- scattered thunderstorms
  [39] = (iconsDir .. 'rain-3.png'),      -- scattered thunderstorms
  [40] = (iconsDir .. 'rain-6.png'),      -- scattered showers
  [41] = (iconsDir .. 'snowflake.png'),   -- heavy snow
  [42] = (iconsDir .. 'snowflake.png'),   -- scattered snow showers
  [43] = (iconsDir .. 'snowflake.png'),   -- heavy snow
  [44] = (iconsDir .. 'cloudy.png'),      -- party cloudy
  [45] = (iconsDir .. 'storm.png'),       -- thundershowers
  [46] = (iconsDir .. 'snowflake.png'),   -- snow showers
  [47] = (iconsDir .. 'lightning.png'),   -- isolated thundershowers
  [3200] = (iconsDir .. 'na.png')         -- not available
}


function weather.setIcon(app, code)
  local iconPath = code and weatherSymbols[code] or weatherSymbols[3200]
  app:setIcon(hs.image.imageFromPath(iconPath):setSize({w=16,h=16}))
end

function weather.setTitle(app, unitSys, temp)
  if unitSys == 'C' then
    local tempCelsius = weather.toCelsius(temp)
    local tempRounded = math.floor(tempCelsius * 10 + 0.5) / 10
    app:setTitle(tempRounded .. ' °C  ')
  else
    app:setTitle(temp .. ' °F  ')
  end
end

function urlencode(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w ])",
      function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str
end

function weather.toCelsius(f)
  return (f - 32) * 5 / 9
end

-- function getWeather(location)
--   local weatherEndpoint = (
--     urlBase .. urlencode(query .. location .. '")') .. '&format=json')
--   return hs.http.get(weatherEndpoint)
-- end

function weather.setForLocation(location, unitSys)
  local weatherEndpoint = (
    urlBase .. urlencode(query .. location .. '")') .. '&format=json')
  hs.http.asyncGet(weatherEndpoint, nil,
    function(code, body, table)
      if code ~= 200 then
        weather.log.i('Could not get weather. Response code: ' .. code)
      else
        weather.log.i('Weather for ' .. location .. ': ' .. body)
        local response = hs.json.decode(body)
        local temp = response.query.results.channel.item.condition.temp
        local code = tonumber(response.query.results.channel.item.condition.code)
        local condition = response.query.results.channel.item.condition.text
        local title = response.query.results.channel.item.title
        weather.setIcon(weather.app, code)
        weather.setTitle(weather.app, unitSys, temp)
        weather.app:setTooltip((title .. '\n' .. 'Condition: ' .. condition))
      end
    end)
end

-- Get weather for current location
-- Hammerspoon needs access to OS location services
function weather.setForCurrentLocation(unitSys)
  if hs.location.services_enabled() then
    hs.location.start()
    hs.timer.doAfter(1,
      function ()
        local loc = hs.location.get()
        hs.location.stop()
        weather.setForLocation('(' .. loc.latitude .. ',' .. loc.longitude .. ')', unitSys)
      end)
  else
    weather.log.i('Location services disabled!')
  end
end

function weather.set(conf)
  if conf.geolocation then
    weather.setForCurrentLocation(conf.units)
  else
    weather.setForLocation(conf.location, conf.units)
  end
end

function weather.update()
  weather.set(weather.config)
end


function weather.start(conf)
  weather.app = hs.menubar.new()
  -- refresh on click
  weather.app:setClickCallback(weather.update)
  -- update weather every so often
  w = hs.timer.doEvery(weather.config.refresh, weather.update)
  -- set initial view
  weather.update()
end


-- Add triggers
-----------------------------------------------
weather.triggers = {}
weather.triggers["Weather Refresh"] = weather.update


----------------------------------------------------------------------------
return weather
