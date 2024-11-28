--*****************************************************************
-- Here you will find all the required content to provide specific
-- features of this module via the 'CSK FlowConfig'.
--*****************************************************************

require('Configuration.DigitalIOManager.FlowConfig.DigitalIOManager_OnNewInputState')
require('Configuration.DigitalIOManager.FlowConfig.DigitalIOManager_Set')

--- Function to react if FlowConfig was updated
local function handleOnClearOldFlow()
  if _G.availableAPIs.default and _G.availableAPIs.specific then
    if digitalIOManager_Model.parameters.flowConfigPriority then
      CSK_DigitalIOManager.clearFlowConfigRelevantConfiguration()
    end
  end
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)