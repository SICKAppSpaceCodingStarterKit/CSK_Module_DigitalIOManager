-- Block namespace
local BLOCK_NAMESPACE = 'DigitalIOManager_FC.Set'
local nameOfModule = 'CSK_DigitalIOManager'

--*************************************************************
--*************************************************************

-- Required to keep track of already allocated resource
local instanceTable = {}

local function setStatus(handle, source)
  local port = Container.get(handle, 'Port')
  local eventToLink, endPos = string.find(source, 'CSK_DigitalIOManager.OnNewInputState')

  if eventToLink then
    local inputPort = string.sub(source, endPos+1, #source)
    CSK_DigitalIOManager.setInputForLink(inputPort)
    CSK_DigitalIOManager.setOutputForLink(port)
    CSK_DigitalIOManager.addLink()

  else
    CSK_DigitalIOManager.setOutputToTrigger(port)
    CSK_DigitalIOManager.setTriggerEvent(source)
    CSK_DigitalIOManager.addTriggerEvent()

    CSK_DigitalIOManager.selectOutputInterface(port)
    CSK_DigitalIOManager.setActiveStatusOutput(true)
  end
end

--*************************************************************
--*************************************************************

local function create(port)

  if nil ~= instanceTable[port] then
    _G.logger:warning(nameOfModule .. ": Instance already in use, please choose another one")
    return nil
  else
    -- Otherwise create handle and store the restriced resource
    local handle = Container.create()
    instanceTable[port] = port
    Container.add(handle, 'Port', port)
    return handle
  end
end
Script.serveFunction(BLOCK_NAMESPACE .. '.create', create)
Script.serveFunction(BLOCK_NAMESPACE .. '.set', setStatus)

-- Function to clear instances
local function handleOnClearOldFlow()
  Script.releaseObject(instanceTable)
  instanceTable = {}
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)