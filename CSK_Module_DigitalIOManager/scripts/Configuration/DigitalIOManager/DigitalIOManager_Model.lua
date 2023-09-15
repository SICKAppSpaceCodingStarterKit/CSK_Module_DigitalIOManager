---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--*****************************************************************
-- Inside of this script, you will find the module definition
-- including its parameters and functions
--*****************************************************************

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************
local nameOfModule = 'CSK_DigitalIOManager'

local digitalIOManager_Model = {}

-- Check if CSK_UserManagement module can be used if wanted
digitalIOManager_Model.userManagementModuleAvailable = CSK_UserManagement ~= nil or false

-- Check if CSK_PersistentData module can be used if wanted
digitalIOManager_Model.persistentModuleAvailable = CSK_PersistentData ~= nil or false

-- Default values for persistent data
-- If available, following values will be updated from data of CSK_PersistentData module (check CSK_PersistentData module for this)
digitalIOManager_Model.parametersName = 'CSK_DigitalIOManager_Parameter' -- name of parameter dataset to be used for this module
digitalIOManager_Model.parameterLoadOnReboot = false -- Status if parameter dataset should be loaded on app/device reboot

digitalIOManager_Model.moduleActive = true

-- check if needed CROWN is available on device
if Connector == nil then
  digitalIOManager_Model.moduleActive = false
  _G.logger:warning(nameOfModule .. ': CROWN is not available. Module is not supported...')
else
  if Connector.DigitalIn == nil then
    digitalIOManager_Model.moduleActive = false
    _G.logger:warning(nameOfModule .. ': CROWN is not available. Module is not supported...')
  end
end

-- Load script to communicate with the DigitalIOManager_Model interface and give access
-- to the DigitalIOManager_Model object.
-- Check / edit this script to see/edit functions which communicate with the UI
local setDigitalIOManager_ModelHandle = require('Configuration/DigitalIOManager/DigitalIOManager_Controller')
setDigitalIOManager_ModelHandle(digitalIOManager_Model)

--Loading helper functions if needed
digitalIOManager_Model.helperFuncs = require('Configuration/DigitalIOManager/helper/funcs')

digitalIOManager_Model.initialized = false -- Status if app initialized already the interfaces after boot up
digitalIOManager_Model.handles = {} -- Handles of DigitalIO interfaces
digitalIOManager_Model.portState = {} -- States of the DigitalIO interfaces
digitalIOManager_Model.digitalInputs = {} -- List of available input interfaces
digitalIOManager_Model.digitalOutputs = {} -- List of available input interfaces

digitalIOManager_Model.forwardFunctions = {} -- List of functions to be used to forward incoming trigger via DigitalIn as events
digitalIOManager_Model.triggerFunctions = {} -- List of functions to be used to forward incoming events to trigger DigitalOut

-- Create parameters / instances for this module
digitalIOManager_Model.parameters = {}
digitalIOManager_Model.parameters.links = {} -- .input/.output/.delay

--- Functions to forward incoming trigger via DigitalInput as event
---@param status boolean Status of port to forward
---@param source string Name of port
local function forwardInputToEvent(status, source)
  _G.logger:info(nameOfModule .. ': Notify event ' .. tostring(digitalIOManager_Model.parameters.forwardEvent[source]) .. ' .. with status: ' .. tostring(status))
  Script.notifyEvent(digitalIOManager_Model.parameters.forwardEvent[source], status)
end

--- Function to set DigitalOutputs if received related event
---@param newState boolean Status of port
---@param port string Name of port
local function setOutputViaEvent(newState, port)
  _G.logger:info(nameOfModule .. ': Set digital output ' .. tostring(port))
  Connector.DigitalOut.set(digitalIOManager_Model.handles[port], newState)
  if newState and digitalIOManager_Model.parameters.outActivationValue[port] ~= 0 then
    Connector.DigitalOut.set(digitalIOManager_Model.handles[port], not newState)
  end
end

if digitalIOManager_Model.moduleActive then

  digitalIOManager_Model.flow = Flow.create() -- Flow to be used for direct wiring signals from DigitalInput to DigitalOutput
  digitalIOManager_Model.flow:setType('CFLOW')

  digitalIOManager_Model.digitalOutputs = Engine.getEnumValues("DigitalOutPorts")
  digitalIOManager_Model.digitalInputs = Engine.getEnumValues("DigitalInPorts")
  for i=1, #digitalIOManager_Model.digitalInputs do
    local id = digitalIOManager_Model.digitalInputs[i]
    local eventName = "CSK_DigitalIOManager.OnNewInputState" .. id
    Script.serveEvent(eventName, eventName, 'bool')
  end

  -- Create functions to forward incoming trigger via DigitalInput as event
  for _, value in pairs(digitalIOManager_Model.digitalInputs) do
    local function addSourcePort(status)
      forwardInputToEvent(status,value)
    end
    digitalIOManager_Model.forwardFunctions[value] = addSourcePort
  end

  -- Create functions to set DigitalOutputs if received related event
  for _, value in pairs(digitalIOManager_Model.digitalOutputs) do
    local function addSourcePort(status)
      setOutputViaEvent(status,value)
    end
    digitalIOManager_Model.triggerFunctions[value] = addSourcePort
  end
end

----------------------------------------------------------------

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to initialize the DigitalIO ports
local function initialize()
  _G.logger:info(nameOfModule .. ': Initialize digital IO ports.')
  digitalIOManager_Model.parameters.active = {} -- Status if port is active to process
  digitalIOManager_Model.parameters.mode = {} -- Port is used by 'SCRIPT', 'FLOW' or 'BLOCKED'
  digitalIOManager_Model.parameters.sensorStatus = {} -- Status of sensor's measurement

  digitalIOManager_Model.parameters.inDebounceValue = {} -- List of Input DebounceValues for the ports
  digitalIOManager_Model.parameters.inDebounceMode = {} -- List of Input DebounceMode for the ports
  digitalIOManager_Model.parameters.inputLogic = {} -- List of Input Logic  for the ports
  digitalIOManager_Model.parameters.forwardEvent = {} -- List of events to forward incoming DigitalIn
  digitalIOManager_Model.parameters.forwardEventDataInfo = {} -- List of InfoTexts for forwarded event

  digitalIOManager_Model.parameters.outActivationMode = {} -- List of Output ActviationModes for all ports
  digitalIOManager_Model.parameters.outActivationValue = {} -- List of Output ActviationValues for all ports
  digitalIOManager_Model.parameters.outputLogic = {} -- List of Output Logics for all ports
  digitalIOManager_Model.parameters.outputMode = {}  -- List of Output Mode for all ports
  digitalIOManager_Model.parameters.triggerEvent = {} -- List of events to forward as digital output for all ports

  for i=1, #digitalIOManager_Model.digitalInputs do
    local id = digitalIOManager_Model.digitalInputs[i]
    digitalIOManager_Model.parameters.active[id] = false --all IOs are inputs as default
    digitalIOManager_Model.parameters.inDebounceValue[id] = 10 -- 10 [ms]
    digitalIOManager_Model.parameters.inDebounceMode[id] = 'TIME_MS' --'TIME_MS', 'INCREMENT_TICK'
    digitalIOManager_Model.parameters.inputLogic[id] = 'ACTIVE_HIGH' -- 'ACTIVE_HIGH', 'ACTIVE_LOW'

    digitalIOManager_Model.parameters.mode[id] = 'SCRIPT' -- 'SCRIPT', 'FLOW'
    digitalIOManager_Model.parameters.sensorStatus[id] = false -- true, false
  end

  for i=1, #digitalIOManager_Model.digitalOutputs do
    local id = digitalIOManager_Model.digitalOutputs[i]
    digitalIOManager_Model.parameters.active[id] = false --all IOs are inputs as default
    digitalIOManager_Model.parameters.outActivationMode[id] = 'TIME_MS' --'TIME_MS', 'INCREMENT_TICK'
    digitalIOManager_Model.parameters.outActivationValue[id] = 100 -- 100 [ms]
    digitalIOManager_Model.parameters.outputLogic[id] = 'ACTIVE_HIGH' -- 'ACTIVE_HIGH', 'ACTIVE_LOW'
    digitalIOManager_Model.parameters.outputMode[id] = 'PUSH_PULL' -- 'HIGH_SIDE', 'LOW_SIDE', 'PUSH_PULL'

    digitalIOManager_Model.parameters.mode[id] = 'SCRIPT' -- 'SCRIPT', 'FLOW'
  end
  CSK_DigitalIOManager.selectInputInterface(digitalIOManager_Model.digitalInputs[1])
  CSK_DigitalIOManager.selectOutputInterface(digitalIOManager_Model.digitalOutputs[1])
  CSK_DigitalIOManager.setInputForLink(digitalIOManager_Model.digitalInputs[1])
  CSK_DigitalIOManager.setOutputForLink(digitalIOManager_Model.digitalOutputs[1])

  CSK_DigitalIOManager.setInputToForward(digitalIOManager_Model.digitalInputs[1])
  CSK_DigitalIOManager.setOutputToTrigger(digitalIOManager_Model.digitalOutputs[1])
end
digitalIOManager_Model.initialize = initialize

--- Function to reset all ports
local function clearAll()
  for _, value in pairs(digitalIOManager_Model.digitalOutputs) do
    if digitalIOManager_Model.handles[value] and digitalIOManager_Model.parameters.triggerEvent[value] and digitalIOManager_Model.triggerFunctions[value] then
      Script.deregister(digitalIOManager_Model.parameters.triggerEvent[value], digitalIOManager_Model.triggerFunctions[value])
    end
  end

  Script.releaseObject(digitalIOManager_Model.handles)
  digitalIOManager_Model.handles = nil

  Script.releaseObject(digitalIOManager_Model.flow)
  digitalIOManager_Model.flow = nil

  collectgarbage()
end
digitalIOManager_Model.clearAll = clearAll

--- Function to setup all configs of all ports if something was changed in the configuration
local function setupAll()

  digitalIOManager_Model.handles = {}
  digitalIOManager_Model.flow = Flow.create()
  digitalIOManager_Model.flow:setType('CFLOW')

  for i=1, #digitalIOManager_Model.digitalInputs do
    local id = digitalIOManager_Model.digitalInputs[i]
    if digitalIOManager_Model.parameters.active[id] == true and digitalIOManager_Model.parameters.mode[id] == 'SCRIPT' then
      digitalIOManager_Model.handles[id] = Connector.DigitalIn.create(digitalIOManager_Model.digitalInputs[i])
      if digitalIOManager_Model.handles[id] then
        digitalIOManager_Model.handles[id]:setDebounceMode(digitalIOManager_Model.parameters.inDebounceMode[id])
        digitalIOManager_Model.handles[id]:setDebounceValue(digitalIOManager_Model.parameters.inDebounceValue[id])
        digitalIOManager_Model.handles[id]:setLogic(digitalIOManager_Model.parameters.inputLogic[id])
        Connector.DigitalIn.register(digitalIOManager_Model.handles[id], "OnChange", function(state) 
        digitalIOManager_Model.parameters.sensorStatus[id]= state end)
        Connector.DigitalIn.register(digitalIOManager_Model.handles[id], "OnChange", CSK_DigitalIOManager.pageCalled)

        if digitalIOManager_Model.parameters.forwardEvent[id] then
          Connector.DigitalIn.register(digitalIOManager_Model.handles[id], "OnChange", digitalIOManager_Model.forwardFunctions[id])
        end
      end
    end
  end

  for i=1, #digitalIOManager_Model.digitalOutputs do
    local id = digitalIOManager_Model.digitalOutputs[i]
    if digitalIOManager_Model.parameters.active[id] == true and digitalIOManager_Model.parameters.mode[id] == 'SCRIPT' then

      digitalIOManager_Model.handles[id] = Connector.DigitalOut.create(digitalIOManager_Model.digitalOutputs[i])
      if digitalIOManager_Model.handles[id] then
        digitalIOManager_Model.handles[id]:setActivationMode(digitalIOManager_Model.parameters.outActivationMode[id])
        digitalIOManager_Model.handles[id]:setActivationValue(digitalIOManager_Model.parameters.outActivationValue[id])
        digitalIOManager_Model.handles[id]:setLogic(digitalIOManager_Model.parameters.outputLogic[id])
        digitalIOManager_Model.handles[id]:setPortOutputMode(digitalIOManager_Model.parameters.outputMode[id])

        if digitalIOManager_Model.parameters.triggerEvent[id] then
          Script.register(digitalIOManager_Model.parameters.triggerEvent[id], digitalIOManager_Model.triggerFunctions[id])
        end
      end
    end
  end

  --Create link in cFlow
  for i=1, #digitalIOManager_Model.parameters.links do

    local input = digitalIOManager_Model.parameters.links[i].input
    local output = digitalIOManager_Model.parameters.links[i].output

    if digitalIOManager_Model.parameters.mode[input] == 'FLOW' and digitalIOManager_Model.parameters.mode[output] == 'FLOW' then
      if not digitalIOManager_Model.flow:hasBlock('DigitalIn'..input) then

        digitalIOManager_Model.flow:addProviderBlock('DigitalIn'..input, 'Connector.DigitalIn.OnChange')
        digitalIOManager_Model.flow:setCreationParameter('DigitalIn'..input, input)
        digitalIOManager_Model.flow:setInitialParameter('DigitalIn'..input, 'Logic', digitalIOManager_Model.parameters.inputLogic[input])
        digitalIOManager_Model.flow:setInitialParameter('DigitalIn'..input, 'DebounceMode', digitalIOManager_Model.parameters.inDebounceMode[input])
        digitalIOManager_Model.flow:setInitialParameter('DigitalIn'..input, 'DebounceValue', digitalIOManager_Model.parameters.inDebounceValue[input])
      end

      if not digitalIOManager_Model.flow:hasBlock('DigitalOut'..output) then
        digitalIOManager_Model.flow:addConsumerBlock('DigitalOut'..output, 'Connector.DigitalOut.set')
        digitalIOManager_Model.flow:setCreationParameter('DigitalOut'..output, digitalIOManager_Model.parameters.links[i].output)
        digitalIOManager_Model.flow:setInitialParameter('DigitalOut'..output, 'Logic', digitalIOManager_Model.parameters.outputLogic[output])
        digitalIOManager_Model.flow:setInitialParameter('DigitalOut'..output, 'PortOutputMode', digitalIOManager_Model.parameters.outputMode[output])
        digitalIOManager_Model.flow:setInitialParameter('DigitalOut'..output, 'ActivationMode', digitalIOManager_Model.parameters.outActivationMode[output])
        digitalIOManager_Model.flow:setInitialParameter('DigitalOut'..output, 'ActivationValue', digitalIOManager_Model.parameters.outActivationValue[output])
      end

      if digitalIOManager_Model.parameters.links[i].delay == 0 then
        digitalIOManager_Model.flow:addLink('DigitalIn'..input..':newState', 'DigitalOut'..output..':newState')
      else
        digitalIOManager_Model.flow:addBlock('Delay'..input..output, 'DigitalLogic.Delay.delay')
        digitalIOManager_Model.flow:setInitialParameter('Delay'..input..output, 'DelayTime', digitalIOManager_Model.parameters.links[i].delay)

        digitalIOManager_Model.flow:addLink('DigitalIn'..input..':newState', 'Delay'..input..output..':signal')
        digitalIOManager_Model.flow:addLink('Delay'..input..output..':delayedSignal', 'DigitalOut'..output..':newState')
      end
    else
      _G.logger:info(nameOfModule .. ': Problem with configured links...')
    end

  end

  digitalIOManager_Model.flow:start()

end
digitalIOManager_Model.setupAll = setupAll

-- Function to call on change for sensor measurement
function handleStateChange(status)

end
-- Initialize and setup digital IO setup
if digitalIOManager_Model.moduleActive then
  initialize()
  setupAll()
  digitalIOManager_Model.initialized = true
end

--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************

return digitalIOManager_Model
