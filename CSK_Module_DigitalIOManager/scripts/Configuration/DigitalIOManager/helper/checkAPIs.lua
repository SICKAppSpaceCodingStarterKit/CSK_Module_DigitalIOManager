---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

-- Load all relevant APIs for this module
--**************************************************************************

local availableAPIs = {}

-- Function to load all default APIs
local function loadAPIs()
  CSK_DigitalIOManager = require 'API.CSK_DigitalIOManager'

  Log = require 'API.Log'
  Log.Handler = require 'API.Log.Handler'
  Log.SharedLogger = require 'API.Log.SharedLogger'

  Container = require 'API.Container'
  Engine = require 'API.Engine'
  Object = require 'API.Object'
  Timer = require 'API.Timer'

  -- Check if related CSK modules are available to be used
  local appList = Engine.listApps()
  for i = 1, #appList do
    if appList[i] == 'CSK_Module_PersistentData' then
      CSK_PersistentData = require 'API.CSK_PersistentData'
    elseif appList[i] == 'CSK_Module_UserManagement' then
      CSK_UserManagement = require 'API.CSK_UserManagement'
    elseif appList[i] == 'CSK_Module_FlowConfig' then
      CSK_FlowConfig = require 'API.CSK_FlowConfig'
    elseif appList[i] == 'CSK_Module_MultiIOLinkSMI' then
      CSK_MultiIOLinkSMI = require 'API.CSK_MultiIOLinkSMI'
    end
  end
end

-- Function to load specific APIs
local function loadSpecificAPIs()
  Flow = require 'API.Flow'
  if not Connector then
    Connector = {}
  end
  Connector.DigitalIn = require 'API.Connector.DigitalIn'
  Connector.DigitalOut = require 'API.Connector.DigitalOut'
end

-- Function to check signal link feature (cFlow IO handling)
local function checkSignalLinkSupport()
  local deviceName = Engine.getTypeName()
  local isSIM300 = string.find(deviceName, 'SIG300') or string.find(deviceName, 'SIM300')
  if isSIM300 then
    return false
  else
    return true
  end
end

availableAPIs.default = xpcall(loadAPIs, debug.traceback) -- TRUE if all default APIs were loaded correctly
availableAPIs.specific = xpcall(loadSpecificAPIs, debug.traceback) -- TRUE if all specific APIs were loaded correctly
availableAPIs.signalLinkSupport = checkSignalLinkSupport() -- TRUE if device supports signal link feature (cFlow IO handling)
availableAPIs.SGI = xpcall(loadSGIAPIs, debug.traceback) -- TRUE if SGI CROWN exists

return availableAPIs
--**************************************************************************