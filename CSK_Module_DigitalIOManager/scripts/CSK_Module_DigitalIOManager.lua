--MIT License
--
--Copyright (c) 2023 SICK AG
--
--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is
--furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all
--copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--SOFTWARE.

---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************

-- If app property "LuaLoadAllEngineAPI" is FALSE, use this to load and check for required APIs
-- This can improve performance of garbage collection
_G.availableAPIs = require('Configuration.DigitalIOManager.helper.checkAPIs') -- can be used to adjust function scope of the module related on available APIs of the device
-----------------------------------------------------------
-- Logger
_G.logger = Log.SharedLogger.create('ModuleLogger')
_G.logHandle = Log.Handler.create()
_G.logHandle:attachToSharedLogger('ModuleLogger')
_G.logHandle:setConsoleSinkEnabled(false) --> Set to TRUE if CSK_Logger module is not used
_G.logHandle:setLevel("ALL")
_G.logHandle:applyConfig()
-----------------------------------------------------------

-- Loading script regarding DigitalIOManager_Model
-- Check this script regarding DigitalIOManager_Model parameters and functions
_G.digitalIOManager_Model = require('Configuration/DigitalIOManager/DigitalIOManager_Model')
require('Configuration/DigitalIOManager/FlowConfig/DigitalIOManager_FlowConfig')

if _G.availableAPIs.default == false or _G.availableAPIs.specific == false then
  _G.logger:warning("CSK_DigitalIOManager: Relevant CROWN(s) not available on device. Module is not supported...")
end

--**************************************************************************
--**********************End Global Scope ***********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to react on startup event of the app
local function main()

  ----------------------------------------------------------------------------------------
  -- INFO: Please check if module will eventually load initial configuration triggered via
  --       event CSK_PersistentData.OnInitialDataLoaded
  --       (see internal variable _G.digitalIOManager_Model.parameterLoadOnReboot)
  --       If so, the app will trigger the "OnDataLoadedOnReboot" event if ready after loading parameters
  --
  -- Can be used e.g. like this
  --[[

  CSK_DigitalIOManager.selectOutputInterface('S1DO1')
  CSK_DigitalIOManager.setActivationMode('TIME_MS')
  CSK_DigitalIOManager.setActivationValue(120)
  CSK_DigitalIOManager.setOutputLogic('ACTIVE_HIGH')
  CSK_DigitalIOManager.setOutputMode('PUSH_PULL')
  CSK_DigitalIOManager.setActiveStatusOutput(true)

  CSK_DigitalIOManager.setInputForLink('S3DI1')
  CSK_DigitalIOManager.setOutputForLink('S2DO1')
  CSK_DigitalIOManager.setDelayForLink(100)
  CSK_DigitalIOManager.addLink()

  CSK_DigitalIOManager.setTriggerEvent('OtherApp.OnNewResult')
  CSK_DigitalIOManager.setOutputToTrigger('S4DO1')
  CSK_DigitalIOManager.addTriggerEvent()
  CSK_DigitalIOManager.selectOutputInterface('S4DO1')
  CSK_DigitalIOManager.setActiveStatusOutput(true)

  CSK_DigitalIOManager.selectInputInterface('S4DI1')
  CSK_DigitalIOManager.setActiveStatusInput(true)
  CSK_DigitalIOManager.setInputToForward('S4DI1')
  CSK_DigitalIOManager.addForwardEvent() -- Will forward new state on event "CSK_DigitalIOManager.OnNewInputStateS4DI1"
  Script.register('CSK_DigitalIOManager.OnNewInputStateS4DI1', handleOnNewInputState) --> Register to this event

  ]]
  ----------------------------------------------------------------------------------------

  CSK_DigitalIOManager.pageCalled() -- Update UI

end
Script.register("Engine.OnStarted", main)

--OR

-- Call function after persistent data was loaded
--Script.register("CSK_DigitalIOManager.OnDataLoadedOnReboot", main)

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************
