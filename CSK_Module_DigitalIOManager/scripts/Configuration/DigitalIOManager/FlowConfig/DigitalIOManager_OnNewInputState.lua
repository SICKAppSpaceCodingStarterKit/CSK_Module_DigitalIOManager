-- Block namespace
local BLOCK_NAMESPACE = "DigitalIOManager_FC.OnNewInputState"
local nameOfModule = 'CSK_DigitalIOManager'

--*************************************************************
--*************************************************************

-- Required to keep track of already allocated resource
local instanceTable = {}

local function register(handle, _ , callback)

  Container.remove(handle, "CB_Function")
  Container.add(handle, "CB_Function", callback)

  ------------------------
  local instance = Container.get(handle, 'Instance') -- Added

  CSK_DigitalIOManager.setInputToForward(instance)
  CSK_DigitalIOManager.addForwardEvent()

  CSK_DigitalIOManager.selectInputInterface(instance)
  CSK_DigitalIOManager.setActiveStatusInput(true)

  local function localCallback()

    if callback ~= nil then
      Script.callFunction(callback, 'CSK_DigitalIOManager.OnNewInputState' .. tostring(instance))
    else
      _G.logger:warning(nameOfModule .. ": " .. BLOCK_NAMESPACE .. ".CB_Function missing!")
    end
  end
  Script.register('CSK_FlowConfig.OnNewFlowConfig', localCallback)

  return true
end

--*************************************************************
--*************************************************************

local function create(instance)

  if nil ~= instanceTable[instance] then
    _G.logger:warning(nameOfModule .. "Instance already in use, please choose another one")
    return nil
  else
    -- Otherwise create handle and store the restriced resource
    local handle = Container.create()
    instanceTable[instance] = instance
    Container.add(handle, 'Instance', instance)
    Container.add(handle, "CB_Function", "")
    return(handle)
  end
end
Script.serveFunction(BLOCK_NAMESPACE .. ".create", create)
Script.serveFunction(BLOCK_NAMESPACE ..".register", register)

-- Function to clear instances
local function handleOnClearOldFlow()
  Script.releaseObject(instanceTable)
  instanceTable = {}
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)