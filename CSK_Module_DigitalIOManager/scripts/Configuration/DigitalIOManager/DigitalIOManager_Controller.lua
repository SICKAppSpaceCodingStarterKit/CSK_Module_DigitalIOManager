---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--***************************************************************
-- Inside of this script, you will find the necessary functions,
-- variables and events to communicate with the DigitalIOManager_Model
--***************************************************************

--**************************************************************************
--************************ Start Global Scope ******************************
--**************************************************************************
local nameOfModule = 'CSK_DigitalIOManager'

-- Timer to update UI via events after page was loaded
local tmrDigitalIOManager = Timer.create()
tmrDigitalIOManager:setExpirationTime(300)
tmrDigitalIOManager:setPeriodic(false)

-- Values to hold temporarly / preset values for digital IO configuration
local selectedInputInterface = ''
local selectedOutputInterface = ''
local selectedLink = ''
local selectedInputForLink = ''
local selectedOutputForLink = ''

local selectedInputToForward = ''
local inputToForwardDataInfo = ''
local selectedOutputToTrigger = ''
local forwardEvent = ''
local triggerEvent = ''
local forwardEventDataInfo = ''
local selectedForwardEventPair = ''
local selectedTriggerEventPair = ''

local presetDelay = 0

-- Reference to global handle
local digitalIOManager_Model

-- ************************ UI Events Start ********************************
-- Only to prevent WARNING messages, but these are only examples/placeholders for dynamically created events/functions
----------------------------------------------------------------
Script.serveEvent("CSK_DigitalIOManager.OnNewInputStateENUM", "DigitalIOManager_.OnNewInputStateENUM")
----------------------------------------------------------------

-- Real events
--------------------------------------------------
Script.serveEvent('CSK_DigitalIOManager.OnNewStatusModuleIsActive', 'DigitalIOManager_OnNewStatusModuleIsActive')
Script.serveEvent("CSK_DigitalIOManager.OnNewEventList", "DigitalIOManager_OnNewEventList")

Script.serveEvent("CSK_DigitalIOManager.OnShowInternalMessages", "DigitalIOManager_OnShowInternalMessages")
Script.serveEvent("CSK_DigitalIOManager.OnNewMessageType", "DigitalIOManager_OnNewMessageType")
Script.serveEvent("CSK_DigitalIOManager.OnNewInternalMessage", "DigitalIOManager_OnNewInternalMessage")

Script.serveEvent("CSK_DigitalIOManager.OnNewOutputPortTable", "DigitalIOManager_OnNewOutputPortTable")
Script.serveEvent("CSK_DigitalIOManager.OnNewInputPortTable", "DigitalIOManager_OnNewInputPortTable")

Script.serveEvent("CSK_DigitalIOManager.OnNewInputSelection", "DigitalIOManager_OnNewInputSelection")
Script.serveEvent("CSK_DigitalIOManager.OnNewOutputSelection", "DigitalIOManager_OnNewOutputSelection")

-- Links
Script.serveEvent("CSK_DigitalIOManager.OnNewLinkList", "DigitalIOManager_OnNewLinkList")
Script.serveEvent("CSK_DigitalIOManager.OnNewLinkSelected", "DigitalIOManager_DigitalIOManager_OnNewLinkSelected")
Script.serveEvent("CSK_DigitalIOManager.OnNewInputPortList", "DigitalIOManager_OnNewInputPortList")
Script.serveEvent("CSK_DigitalIOManager.OnNewOutputPortList", "DigitalIOManager_OnNewOutputPortList")

Script.serveEvent("CSK_DigitalIOManager.OnNewInputForLinkSelected", "DigitalIOManager_OnNewInputForLinkSelected")
Script.serveEvent("CSK_DigitalIOManager.OnNewOutputForLinkSelected", "DigitalIOManager_OnNewOutputForLinkSelected")
Script.serveEvent("CSK_DigitalIOManager.OnNewLinkDelay", "DigitalIOManager_OnNewLinkDelay")

Script.serveEvent("CSK_DigitalIOManager.OnNewActiveStatusInput", "DigitalIOManager_OnNewActiveStatusInput")
Script.serveEvent("CSK_DigitalIOManager.OnNewDebounceMode", "DigitalIOManager_OnNewDebounceMode")
Script.serveEvent("CSK_DigitalIOManager.OnNewDebounceValue", "DigitalIOManager_OnNewDebounceValue")
Script.serveEvent("CSK_DigitalIOManager.OnNewInputLogic", "DigitalIOManager_OnNewInputLogic")

Script.serveEvent("CSK_DigitalIOManager.OnNewActiveStatusOutput", "DigitalIOManager_OnNewActiveStatusOutput")
Script.serveEvent("CSK_DigitalIOManager.OnNewActivationMode", "DigitalIOManager_OnNewActivationMode")
Script.serveEvent("CSK_DigitalIOManager.OnNewActivationValue", "DigitalIOManager_OnNewActivationValue")
Script.serveEvent("CSK_DigitalIOManager.OnNewOutputLogic", "DigitalIOManager_OnNewOutputLogic")
Script.serveEvent("CSK_DigitalIOManager.OnNewOutputMode", "DigitalIOManager_OnNewOutputMode")

Script.serveEvent("CSK_DigitalIOManager.OnNewForwardEvent", "DigitalIOManager_OnNewForwardEvent")
Script.serveEvent("CSK_DigitalIOManager.OnNewTriggerEvent", "DigitalIOManager_OnNewTriggerEvent")
Script.serveEvent("CSK_DigitalIOManager.OnNewInputToForward", "DigitalIOManager_OnNewInputToForward")
Script.serveEvent("CSK_DigitalIOManager.OnNewInputToForwardDataInfo", "DigitalIOManager_OnNewInputToForwardDataInfo")
Script.serveEvent("CSK_DigitalIOManager.OnNewOutputToTrigger", "DigitalIOManager_OnNewOutputToTrigger")

Script.serveEvent("CSK_DigitalIOManager.OnNewForwardTriggerList", "DigitalIOManager_OnNewForwardTriggerList")
Script.serveEvent("CSK_DigitalIOManager.OnNewSetOutputByEventList", "DigitalIOManager_OnNewSetOutputByEventList")

Script.serveEvent("CSK_DigitalIOManager.OnUserLevelOperatorActive", "DigitalIOManager_OnUserLevelOperatorActive")
Script.serveEvent("CSK_DigitalIOManager.OnUserLevelMaintenanceActive", "DigitalIOManager_OnUserLevelMaintenanceActive")
Script.serveEvent("CSK_DigitalIOManager.OnUserLevelServiceActive", "DigitalIOManager_OnUserLevelServiceActive")
Script.serveEvent("CSK_DigitalIOManager.OnUserLevelAdminActive", "DigitalIOManager_OnUserLevelAdminActive")

Script.serveEvent("CSK_DigitalIOManager.OnNewStatusLoadParameterOnReboot", "DigitalIOManager_OnNewStatusLoadParameterOnReboot")
Script.serveEvent("CSK_DigitalIOManager.OnPersistentDataModuleAvailable", "DigitalIOManager_OnPersistentDataModuleAvailable")
Script.serveEvent("CSK_DigitalIOManager.OnDataLoadedOnReboot", "DigitalIOManager_OnDataLoadedOnReboot")
Script.serveEvent("CSK_DigitalIOManager.OnNewParameterName", "DigitalIOManager_OnNewParameterName")

-- ************************ UI Events End **********************************

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

-- Functions to forward logged in user roles via CSK_UserManagement module (if available)
-- ***********************************************
--- Function to react on status change of Operator user level
---@param status boolean Status if Operator level is active
local function handleOnUserLevelOperatorActive(status)
  Script.notifyEvent("DigitalIOManager_OnUserLevelOperatorActive", status)
end

--- Function to react on status change of Maintenance user level
---@param status boolean Status if Maintenance level is active
local function handleOnUserLevelMaintenanceActive(status)
  Script.notifyEvent("DigitalIOManager_OnUserLevelMaintenanceActive", status)
end

--- Function to react on status change of Service user level
---@param status boolean Status if Service level is active
local function handleOnUserLevelServiceActive(status)
  Script.notifyEvent("DigitalIOManager_OnUserLevelServiceActive", status)
end

--- Function to react on status change of Admin user level
---@param status boolean Status if Admin level is active
local function handleOnUserLevelAdminActive(status)
  Script.notifyEvent("DigitalIOManager_OnUserLevelAdminActive", status)
end

--- Function to get access to the digitalIOManager_Model object
---@param handle handle Handle of digitalIOManager_Model object
local function setDigitalIOManager_Model_Handle(handle)
  digitalIOManager_Model = handle
  if digitalIOManager_Model.userManagementModuleAvailable then
    -- Register on events of CSK_UserManagement module if available
    Script.register('CSK_UserManagement.OnUserLevelOperatorActive', handleOnUserLevelOperatorActive)
    Script.register('CSK_UserManagement.OnUserLevelMaintenanceActive', handleOnUserLevelMaintenanceActive)
    Script.register('CSK_UserManagement.OnUserLevelServiceActive', handleOnUserLevelServiceActive)
    Script.register('CSK_UserManagement.OnUserLevelAdminActive', handleOnUserLevelAdminActive)
  end
  Script.releaseObject(handle)
end

--- Function to update user levels
local function updateUserLevel()
  if digitalIOManager_Model.userManagementModuleAvailable then
    -- Trigger CSK_UserManagement module to provide events regarding user role
    CSK_UserManagement.pageCalled()
  else
    -- If CSK_UserManagement is not active, show everything
    Script.notifyEvent("DigitalIOManager_OnUserLevelOperatorActive", true)
    Script.notifyEvent("DigitalIOManager_OnUserLevelMaintenanceActive", true)
    Script.notifyEvent("DigitalIOManager_OnUserLevelServiceActive", true)
    Script.notifyEvent("DigitalIOManager_OnUserLevelAdminActive", true)
  end
end

--- Function to send all relevant values to UI on resume
local function handleOnExpiredTmrDigitalIOManager()

  updateUserLevel()

  selectedLink = ''
  selectedForwardEventPair = ''
  selectedTriggerEventPair = ''

  Script.notifyEvent("DigitalIOManager_OnNewStatusModuleIsActive", digitalIOManager_Model.moduleActive)

  Script.notifyEvent("DigitalIOManager_OnNewInputPortTable", digitalIOManager_Model.helperFuncs.createJsonList('input', digitalIOManager_Model.parameters.inDebounceMode, digitalIOManager_Model.parameters.active, digitalIOManager_Model.parameters.inDebounceMode, digitalIOManager_Model.parameters.inDebounceValue, digitalIOManager_Model.parameters.inputLogic, nil, digitalIOManager_Model.parameters.mode, digitalIOManager_Model.parameters.sensorStatus))
  Script.notifyEvent("DigitalIOManager_OnNewOutputPortTable", digitalIOManager_Model.helperFuncs.createJsonList('output', digitalIOManager_Model.parameters.outActivationMode, digitalIOManager_Model.parameters.active, digitalIOManager_Model.parameters.outActivationMode, digitalIOManager_Model.parameters.outActivationValue, digitalIOManager_Model.parameters.outputLogic, digitalIOManager_Model.parameters.outputMode, digitalIOManager_Model.parameters.mode))

  Script.notifyEvent("DigitalIOManager_OnNewInputPortList", digitalIOManager_Model.helperFuncs.createStringListBySimpleTable(digitalIOManager_Model.digitalInputs))
  Script.notifyEvent("DigitalIOManager_OnNewOutputPortList", digitalIOManager_Model.helperFuncs.createStringListBySimpleTable(digitalIOManager_Model.digitalOutputs))

  Script.notifyEvent("DigitalIOManager_OnNewInputForLinkSelected", selectedInputForLink)
  Script.notifyEvent("DigitalIOManager_OnNewOutputForLinkSelected", selectedOutputForLink)
  Script.notifyEvent("DigitalIOManager_OnNewLinkDelay", presetDelay)

  Script.notifyEvent("DigitalIOManager_OnNewLinkList", digitalIOManager_Model.helperFuncs.createJsonList('links', digitalIOManager_Model.parameters.links))

  Script.notifyEvent("DigitalIOManager_OnNewInputSelection", selectedInputInterface)
  Script.notifyEvent("DigitalIOManager_OnNewOutputSelection", selectedOutputInterface)

  if selectedInputInterface ~= '' then
    Script.notifyEvent("DigitalIOManager_OnNewActiveStatusInput", digitalIOManager_Model.parameters.active[selectedInputInterface])
    Script.notifyEvent("DigitalIOManager_OnNewDebounceMode", digitalIOManager_Model.parameters.inDebounceMode[selectedInputInterface])
    Script.notifyEvent("DigitalIOManager_OnNewDebounceValue", digitalIOManager_Model.parameters.inDebounceValue[selectedInputInterface])
    Script.notifyEvent("DigitalIOManager_OnNewInputLogic", digitalIOManager_Model.parameters.inputLogic[selectedInputInterface])

  end
  if selectedOutputInterface ~= '' then
    Script.notifyEvent("DigitalIOManager_OnNewActiveStatusOutput", digitalIOManager_Model.parameters.active[selectedOutputInterface])
    Script.notifyEvent("DigitalIOManager_OnNewActivationMode", digitalIOManager_Model.parameters.outActivationMode[selectedOutputInterface])
    Script.notifyEvent("DigitalIOManager_OnNewActivationValue", digitalIOManager_Model.parameters.outActivationValue[selectedOutputInterface])
    Script.notifyEvent("DigitalIOManager_OnNewOutputLogic", digitalIOManager_Model.parameters.outputLogic[selectedOutputInterface])
    Script.notifyEvent("DigitalIOManager_OnNewOutputMode", digitalIOManager_Model.parameters.outputMode[selectedOutputInterface])
  end

  Script.notifyEvent("DigitalIOManager_OnNewForwardTriggerList", digitalIOManager_Model.helperFuncs.createJsonList('forwardTrigger', digitalIOManager_Model.parameters.inDebounceMode, digitalIOManager_Model.parameters.forwardEvent, digitalIOManager_Model.parameters.forwardEventDataInfo))
  Script.notifyEvent("DigitalIOManager_OnNewSetOutputByEventList", digitalIOManager_Model.helperFuncs.createJsonList('outputByEvent', digitalIOManager_Model.parameters.outActivationMode, digitalIOManager_Model.parameters.triggerEvent))

  Script.notifyEvent("DigitalIOManager_OnNewTriggerEvent", triggerEvent)
  Script.notifyEvent("DigitalIOManager_OnNewInputToForward", selectedInputToForward)
  Script.notifyEvent("DigitalIOManager_OnNewInputToForwardDataInfo", inputToForwardDataInfo)

  Script.notifyEvent("DigitalIOManager_OnNewOutputToTrigger", selectedOutputToTrigger)

  Script.notifyEvent("DigitalIOManager_OnNewStatusLoadParameterOnReboot", digitalIOManager_Model.parameterLoadOnReboot)
  Script.notifyEvent("DigitalIOManager_OnPersistentDataModuleAvailable", digitalIOManager_Model.persistentModuleAvailable)
  Script.notifyEvent("DigitalIOManager_OnNewParameterName", digitalIOManager_Model.parametersName)

end
Timer.register(tmrDigitalIOManager, "OnExpired", handleOnExpiredTmrDigitalIOManager)

-- ********************* UI Setting / Submit Functions Start ********************

local function pageCalled()
  updateUserLevel() -- try to hide user specific content asap
  tmrDigitalIOManager:start()
  return ''
end
Script.serveFunction("CSK_DigitalIOManager.pageCalled", pageCalled)

--- Function to get the current selected interface
---@param selection string Full text of selection
---@param pattern string Pattern to search for
local function setSelection(selection, pattern)
  local selected
  if selection == "" then
    selected = ''
  else
    local _, pos = string.find(selection, pattern)
    if pos == nil then
      _G.logger:info(nameOfModule .. ": Did not find selection")
      selected = ''
    else
      pos = tonumber(pos)
      local endPos = string.find(selection, '"', pos+1)
      selected = string.sub(selection, pos+1, endPos-1)

      if selected == nil then
        selected = ''
      end
    end
  end
  return selected
end

local function selectInputInterface(selection)
  if digitalIOManager_Model.parameters.inDebounceMode[selection] then
    selectedInputInterface = selection
  else
    selectedInputInterface = setSelection(selection, '"DigitalInput":"')
  end
  _G.logger:info(nameOfModule .. ": Selected DigitalIO interface = " .. tostring(selectedInputInterface))
  if digitalIOManager_Model.initialized then
    handleOnExpiredTmrDigitalIOManager()
  end
end
Script.serveFunction("CSK_DigitalIOManager.selectInputInterface", selectInputInterface)

local function selectOutputInterface(selection)
  if digitalIOManager_Model.parameters.outActivationMode[selection] then
    selectedOutputInterface = selection
  else
    selectedOutputInterface = setSelection(selection, '"DigitalOutput":"')
  end
  _G.logger:info(nameOfModule .. ": Selected DigitalIO interface = " .. tostring(selectedOutputInterface))
  if digitalIOManager_Model.initialized then
    handleOnExpiredTmrDigitalIOManager()
  end
end
Script.serveFunction("CSK_DigitalIOManager.selectOutputInterface", selectOutputInterface)

--- Function to activate new setup
local function activateNewSetup()
  digitalIOManager_Model.clearAll()
  digitalIOManager_Model.setupAll()
  handleOnExpiredTmrDigitalIOManager()
end

--- Function to check if configuration is possible to set
---@param interfaceA string Interface 1
---@param interfaceB string Interface 2
local function checkConfig(interfaceA, interfaceB)
  -- Check for other Connector if pin is configureable
  local pin = string.sub(interfaceA, #interfaceA)
  local port = string.sub(interfaceA, 2, 2)
  local portType = string.sub(interfaceA, 4, 4)

  local pinB, portB
  if interfaceB then
    pinB = string.sub(interfaceB, #interfaceB)
    portB = string.sub(interfaceB, 2, 2)

    if port == portB and pin == pinB then
      return false
    end
  end

  local portToCheck
  if portType == 'I' then
    portToCheck = 'DO'
  else
    portToCheck = 'DI'
  end

  if digitalIOManager_Model.parameters.active['S'..port..portToCheck..pin] == true then
    return false
  else
    return true
  end
end

local function setActiveStatusInput(status)
  -- Check for other Connector if pin is configureable
  if checkConfig(selectedInputInterface) == false or digitalIOManager_Model.parameters.mode[selectedInputInterface] == 'BLOCKED'then

    _G.logger:warning(nameOfModule .. ": Port config error. Not possible to use same port in flow and script.")
    status = false
    Script.notifyEvent('DigitalIOManager_OnShowInternalMessages', 'true')
    Script.notifyEvent('DigitalIOManager_OnNewMessageType', 'warning')
    Script.notifyEvent('DigitalIOManager_OnNewInternalMessage', 'Port currently in other configuration')
  else
    Script.notifyEvent('DigitalIOManager_OnShowInternalMessages', 'false')
  end

  _G.logger:info(nameOfModule .. ": Set active status to " .. tostring(status))
  digitalIOManager_Model.parameters.active[selectedInputInterface] = status
  activateNewSetup()
end
Script.serveFunction("CSK_DigitalIOManager.setActiveStatusInput", setActiveStatusInput)

local function setDebounceMode(mode)
  _G.logger:info(nameOfModule .. ": Set debounce mode to " .. tostring(mode))
  digitalIOManager_Model.parameters.inDebounceMode[selectedInputInterface] = mode
  activateNewSetup()
end
Script.serveFunction("CSK_DigitalIOManager.setDebounceMode", setDebounceMode)

local function setDebounceValue(value)
  _G.logger:info(nameOfModule .. ": Set debounce value to " .. tostring(value))
  digitalIOManager_Model.parameters.inDebounceValue[selectedInputInterface] = value
  activateNewSetup()
end
Script.serveFunction("CSK_DigitalIOManager.setDebounceValue", setDebounceValue)

local function setInputLogic(logic)
  _G.logger:info(nameOfModule .. ": Set input logic to " .. tostring(logic))
  digitalIOManager_Model.parameters.inputLogic[selectedInputInterface] = logic
  activateNewSetup()
end
Script.serveFunction("CSK_DigitalIOManager.setInputLogic", setInputLogic)

local function getInputState()
  local state = digitalIOManager_Model.handles[selectedInputInterface]:get()
  return state
end
Script.serveFunction("CSK_DigitalIOManager.getInputState", getInputState)

------------------------------------

local function setActiveStatusOutput(status)
  if checkConfig(selectedOutputInterface) == false or digitalIOManager_Model.parameters.mode[selectedInputInterface] == 'BLOCKED' then
    _G.logger:warning(nameOfModule .. ": Port config error. Not possible to use same port in flow and script.")
    status = false
    Script.notifyEvent('DigitalIOManager_OnShowInternalMessages', 'true')
    Script.notifyEvent('DigitalIOManager_OnNewMessageType', 'warning')
    Script.notifyEvent('DigitalIOManager_OnNewInternalMessage', 'Port currently in other configuration')
  else
    Script.notifyEvent('DigitalIOManager_OnShowInternalMessages', 'false')
  end

  _G.logger:info(nameOfModule .. ": Set active status to " .. tostring(status))
  digitalIOManager_Model.parameters.active[selectedOutputInterface] = status
  activateNewSetup()
end
Script.serveFunction("CSK_DigitalIOManager.setActiveStatusOutput", setActiveStatusOutput)

local function setActivationMode(mode)
  _G.logger:info(nameOfModule .. ": Set activation mode to " .. tostring(mode))
  digitalIOManager_Model.parameters.outActivationMode[selectedOutputInterface] = mode
  activateNewSetup()
end
Script.serveFunction("CSK_DigitalIOManager.setActivationMode", setActivationMode)

local function setActivationValue(value)
  _G.logger:info(nameOfModule .. ": Set activation value to " .. tostring(value))
  digitalIOManager_Model.parameters.outActivationValue[selectedOutputInterface] = value
  activateNewSetup()
end
Script.serveFunction("CSK_DigitalIOManager.setActivationValue", setActivationValue)

local function setOutputLogic(logic)
  _G.logger:info(nameOfModule .. ": Set output logic to " .. tostring(logic))
  digitalIOManager_Model.parameters.outputLogic[selectedOutputInterface] = logic
  activateNewSetup()
end
Script.serveFunction("CSK_DigitalIOManager.setOutputLogic", setOutputLogic)

local function setOutputMode(mode)
  _G.logger:info(nameOfModule .. ": Set output mode to " .. tostring(mode))
  digitalIOManager_Model.parameters.outputMode[selectedOutputInterface] = mode
  activateNewSetup()
end
Script.serveFunction("CSK_DigitalIOManager.setOutputMode", setOutputMode)

local function setOutput(newState)
  _G.logger:info(nameOfModule .. ": Set output to " .. tostring(newState))
  Connector.DigitalOut.set(digitalIOManager_Model.handles[selectedOutputInterface], newState)
end
Script.serveFunction("CSK_DigitalIOManager.setOutput", setOutput)

----------------------------------------------------------------------------
-------------------------------- LINK SECTION ------------------------------
----------------------------------------------------------------------------

local function selectLink(selection)
  selectedLink = setSelection(selection, '"LinkNo":"')
  if tonumber(selectedLink) then
    _G.logger:info(nameOfModule .. ": Select link no. " .. tostring(selectedLink))
    selectedInputForLink = digitalIOManager_Model.parameters.links[tonumber(selectedLink)].input
    selectedOutputForLink = digitalIOManager_Model.parameters.links[tonumber(selectedLink)].output
    presetDelay = digitalIOManager_Model.parameters.links[tonumber(selectedLink)].delay

    Script.notifyEvent("DigitalIOManager_OnNewInputForLinkSelected", selectedInputForLink)
    Script.notifyEvent("DigitalIOManager_OnNewOutputForLinkSelected", selectedOutputForLink)
    Script.notifyEvent("DigitalIOManager_OnNewLinkDelay", presetDelay)
  end
end
Script.serveFunction("CSK_DigitalIOManager.selectLink", selectLink)

local function setInputForLink(port)
  _G.logger:info(nameOfModule .. ": Select input for link: " .. tostring(port))
  selectedInputForLink = port
end
Script.serveFunction("CSK_DigitalIOManager.setInputForLink", setInputForLink)

local function setOutputForLink(port)
  _G.logger:info(nameOfModule .. ": Select output for link: " .. tostring(port))
  selectedOutputForLink = port
end
Script.serveFunction("CSK_DigitalIOManager.setOutputForLink", setOutputForLink)

local function addLink()

  if checkConfig(selectedInputForLink, selectedOutputForLink) == true and checkConfig(selectedInputForLink) == true and checkConfig(selectedOutputForLink) == true then

    _G.logger:info(nameOfModule .. ": Add link.")
    local tempLink = {}
    tempLink.input = selectedInputForLink
    tempLink.output = selectedOutputForLink
    tempLink.delay = presetDelay

    table.insert(digitalIOManager_Model.parameters.links, tempLink)

    digitalIOManager_Model.parameters.mode[selectedInputForLink] = 'FLOW'
    digitalIOManager_Model.parameters.mode[selectedOutputForLink] = 'FLOW'

    digitalIOManager_Model.parameters.active[selectedInputForLink] = true
    digitalIOManager_Model.parameters.active[selectedOutputForLink] = true

    digitalIOManager_Model.helperFuncs.createJsonList('links', digitalIOManager_Model.parameters.links)

    Script.notifyEvent('DigitalIOManager_OnShowInternalMessages', 'false')
    activateNewSetup()
  else
    Script.notifyEvent('DigitalIOManager_OnShowInternalMessages', 'true')
    Script.notifyEvent('DigitalIOManager_OnNewMessageType', 'warning')
    Script.notifyEvent('DigitalIOManager_OnNewInternalMessage', 'Current setting of (optional) ports not correct. Please check first')
    _G.logger:warning(nameOfModule .. ": Current setting of (optional) ports not correct. Please check first.")
  end
end
Script.serveFunction("CSK_DigitalIOManager.addLink", addLink)

local function removeLink()
  if tonumber(selectedLink) then

    _G.logger:info(nameOfModule .. ": Remove link")

    local input = digitalIOManager_Model.parameters.links[tonumber(selectedLink)].input
    local output = digitalIOManager_Model.parameters.links[tonumber(selectedLink)].output

    if not digitalIOManager_Model.flow:hasBlock('DigitalIn'..input) then
      digitalIOManager_Model.parameters.mode[input] = 'SCRIPT'
      digitalIOManager_Model.parameters.active[input] = false
    end

    if not digitalIOManager_Model.flow:hasBlock('DigitalOut'..output) then
      digitalIOManager_Model.parameters.mode[output] = 'SCRIPT'
      digitalIOManager_Model.parameters.active[output] = false
    end

    table.remove(digitalIOManager_Model.parameters.links, tonumber(selectedLink))
    activateNewSetup()
  else
    _G.logger:warning(nameOfModule .. ": No link to remove.")
  end
end
Script.serveFunction("CSK_DigitalIOManager.removeLink", removeLink)

local function setDelayForLink(value)
  presetDelay = value
  _G.logger:info(nameOfModule .. ": Set new delay for link: " .. tostring(value))

  if tonumber(selectedLink) then
    removeLink()
    addLink()
  end
end
Script.serveFunction("CSK_DigitalIOManager.setDelayForLink", setDelayForLink)

local function selectForwardInputToEventPair(selection)
  if digitalIOManager_Model.parameters.forwardEvent[selection] then
    selectedForwardEventPair = selection
  else
    selectedForwardEventPair = setSelection(selection, '"FromInput":"')
  end
  _G.logger:info(nameOfModule .. ": Select input to forward via event: " .. tostring(selectedForwardEventPair))
end
Script.serveFunction("CSK_DigitalIOManager.selectForwardInputToEventPair", selectForwardInputToEventPair)

local function selectOutputToSetByEventPair(selection)
  if digitalIOManager_Model.parameters.triggerEvent[selection] then
    selectedTriggerEventPair = selection
  else
    selectedTriggerEventPair = setSelection(selection, '"SetOutput":"')
  end
  _G.logger:info(nameOfModule .. ": Select output to set by event: " .. tostring(selectedTriggerEventPair))
end
Script.serveFunction("CSK_DigitalIOManager.selectOutputToSetByEventPair", selectOutputToSetByEventPair)

local function getForwardEventList()

  local listAllEvents = {}
  local listAllInfoTexts = {}

  for key, value in pairs(digitalIOManager_Model.parameters.inDebounceMode) do
    if digitalIOManager_Model.parameters.forwardEvent[key] then
      table.insert(listAllEvents, digitalIOManager_Model.parameters.forwardEvent[key])
      table.insert(listAllInfoTexts, digitalIOManager_Model.parameters.forwardEventDataInfo[key])
    end
  end

  return listAllEvents, listAllInfoTexts
end
Script.serveFunction("CSK_DigitalIOManager.getForwardEventList", getForwardEventList)

local function addForwardEvent()
  if selectedInputToForward ~= '' and digitalIOManager_Model.parameters.mode[selectedInputToForward] == 'SCRIPT' then
    _G.logger:info(nameOfModule .. ": Add forward event.")
    digitalIOManager_Model.parameters.forwardEvent[selectedInputToForward] = 'CSK_DigitalIOManager.OnNewInputState' .. selectedInputToForward
    digitalIOManager_Model.parameters.forwardEventDataInfo[selectedInputToForward] = inputToForwardDataInfo

    local events, texts = getForwardEventList()
    Script.notifyEvent('DigitalIOManager_OnNewEventList', events, texts)

    activateNewSetup()
  else
    _G.logger:warning(nameOfModule .. ": No correct config of ports to add event...")
  end
end
Script.serveFunction("CSK_DigitalIOManager.addForwardEvent", addForwardEvent)

local function addTriggerEvent()
  if selectedOutputToTrigger ~= '' and triggerEvent ~= '' and digitalIOManager_Model.parameters.mode[selectedOutputToTrigger] == 'SCRIPT' then
    _G.logger:info(nameOfModule .. ": Add trigger event.")
    digitalIOManager_Model.parameters.triggerEvent[selectedOutputToTrigger] = triggerEvent
    activateNewSetup()
  else
    _G.logger:warning(nameOfModule .. ": No correct config of ports to add event...")
  end
end
Script.serveFunction("CSK_DigitalIOManager.addTriggerEvent", addTriggerEvent)

local function removeTriggerEvent()
  if selectedTriggerEventPair ~= '' and selectedTriggerEventPair ~= '-' then
    _G.logger:info(nameOfModule .. ": Remove trigger event.")
    Script.deregister(digitalIOManager_Model.parameters.triggerEvent[selectedTriggerEventPair], digitalIOManager_Model.triggerFunctions[selectedTriggerEventPair])
    digitalIOManager_Model.parameters.triggerEvent[selectedTriggerEventPair] = nil
    activateNewSetup()
  else
    _G.logger:warning(nameOfModule .. ": No trigger event to remove.")
  end
end
Script.serveFunction("CSK_DigitalIOManager.removeTriggerEvent", removeTriggerEvent)

local function removeForwardEvent()
  if selectedForwardEventPair ~= '' then
    _G.logger:info(nameOfModule .. ": Remove forward event.")
    digitalIOManager_Model.parameters.forwardEvent[selectedForwardEventPair] = nil
    digitalIOManager_Model.parameters.forwardEventDataInfo[selectedForwardEventPair] = nil
    activateNewSetup()
  else
    _G.logger:warning(nameOfModule .. ": No trigger event to remove.")
  end
end
Script.serveFunction("CSK_DigitalIOManager.removeForwardEvent", removeForwardEvent)

-- Not used. Will be set automatically by ENUM
local function setForwardEvent(event)
  --forwardEvent = event
end
Script.serveFunction("CSK_DigitalIOManager.setForwardEvent", setForwardEvent)

local function setTriggerEvent(event)
  _G.logger:info(nameOfModule .. ": Set trigger event to: " .. tostring(event))
  triggerEvent = event
end
Script.serveFunction("CSK_DigitalIOManager.setTriggerEvent", setTriggerEvent)

local function setInputToForward(port)
  _G.logger:info(nameOfModule .. ": Set input to forward: " .. tostring(port))
  selectedInputToForward = port
end
Script.serveFunction("CSK_DigitalIOManager.setInputToForward", setInputToForward)

local function setInputToForwardDataInfo(info)
  _G.logger:info(nameOfModule .. ": Set input to forward dataInfo: " .. tostring(port))
  inputToForwardDataInfo = info
end
Script.serveFunction("CSK_DigitalIOManager.setInputToForwardDataInfo", setInputToForwardDataInfo)

local function setOutputToTrigger(port)
  _G.logger:info(nameOfModule .. ": Set output to trigger: " .. tostring(port))
  selectedOutputToTrigger = port
end
Script.serveFunction("CSK_DigitalIOManager.setOutputToTrigger", setOutputToTrigger)

local function blockSensorPort(port)
  _G.logger:info(nameOfModule .. ": Block port ".. port .. " to use in other app.")
  if digitalIOManager_Model.parameters.mode[port] then
    digitalIOManager_Model.parameters.mode[port] = 'BLOCKED'
    activateNewSetup()
    return true
  else
    _G.logger:info(nameOfModule .. ": Port ".. port .. " is not available.")
    return false
  end
end
Script.serveFunction('CSK_DigitalIOManager.blockSensorPort', blockSensorPort)

local function freeSensorPort(port)
  _G.logger:info(nameOfModule .. ": Free port ".. port .. " to use in other app.")
  if digitalIOManager_Model.parameters.mode[port] then
    if digitalIOManager_Model.parameters.mode[port] == 'BLOCKED' then
      digitalIOManager_Model.parameters.mode[port] = 'SCRIPT'
      activateNewSetup()
      return true
    else
      _G.logger:info(nameOfModule .. ": Port was not blocked. No need to free it.")
    end
  else
    _G.logger:info(nameOfModule .. ": Port is not available.")
    return false
  end
end
Script.serveFunction('CSK_DigitalIOManager.freeSensorPort', freeSensorPort)

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  _G.logger:info(nameOfModule .. ": Set parameter name: " .. tostring(name))
  digitalIOManager_Model.parametersName = name
end
Script.serveFunction("CSK_DigitalIOManager.setParameterName", setParameterName)

local function sendParameters()
  if digitalIOManager_Model.persistentModuleAvailable then
    CSK_PersistentData.addParameter(digitalIOManager_Model.helperFuncs.convertTable2Container(digitalIOManager_Model.parameters), digitalIOManager_Model.parametersName)
    CSK_PersistentData.setModuleParameterName(nameOfModule, digitalIOManager_Model.parametersName, digitalIOManager_Model.parameterLoadOnReboot)
    _G.logger:info(nameOfModule .. ": Send DigitalIOManager parameters with name '" .. digitalIOManager_Model.parametersName .. "' to CSK_PersistentData module.")
    CSK_PersistentData.saveData()
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_DigitalIOManager.sendParameters", sendParameters)

local function loadParameters()
  if digitalIOManager_Model.persistentModuleAvailable then
    local data = CSK_PersistentData.getParameter(digitalIOManager_Model.parametersName)
    if data then
      _G.logger:info(nameOfModule .. ": Loaded parameters from CSK_PersistentData module.")
      digitalIOManager_Model.parameters = digitalIOManager_Model.helperFuncs.convertContainer2Table(data)
      activateNewSetup()
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_DigitalIOManager.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  digitalIOManager_Model.parameterLoadOnReboot = status
  _G.logger:info(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
end
Script.serveFunction("CSK_DigitalIOManager.setLoadOnReboot", setLoadOnReboot)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()

  _G.logger:info(nameOfModule .. ': Try to initially load parameter from CSK_PersistentData module.')
  if string.sub(CSK_PersistentData.getVersion(), 1, 1) == '1' then

    _G.logger:warning(nameOfModule .. ': CSK_PersistentData module is too old and will not work. Please update CSK_PersistentData module.')

    digitalIOManager_Model.persistentModuleAvailable = false
  else

    local parameterName, loadOnReboot = CSK_PersistentData.getModuleParameterName(nameOfModule)

    if parameterName then
      digitalIOManager_Model.parametersName = parameterName
      digitalIOManager_Model.parameterLoadOnReboot = loadOnReboot
    end

    if digitalIOManager_Model.parameterLoadOnReboot then
      loadParameters()
    end
  end
  Script.notifyEvent('DigitalIOManager_OnDataLoadedOnReboot')
end
Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)

-- *************************************************
-- END of functions for CSK_PersistentData module usage
-- *************************************************

return setDigitalIOManager_Model_Handle

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************

