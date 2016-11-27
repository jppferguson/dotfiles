
-- Logging
-----------------------------------------------
local log = {}
local logger = hs.logger
local logID = hs.host.localizedName()
local config = jspoon.config
local alert = jspoon.utils.alert

-- Set global log level
-- logger.defaultLogLevel = config.loglevel

-- Set up loggers
-----------------------------------------------
log.loggerDebug = logger.new(logID, 'debug')
log.loggerInfo = logger.new(logID, 'info')
log.loggerWarn = logger.new(logID, 'warning')


function log.simple(message)
  alert.simple(message)
end

function log.debug(message)
  log.loggerDebug.i(message)
end

function log.info(message)
  log.loggerInfo.i(message)
end

function log.warn(message)
  log.loggerWarn.i(message)
end


log.info("Logging initialised")

----------------------------------------------------------------------------
return log
