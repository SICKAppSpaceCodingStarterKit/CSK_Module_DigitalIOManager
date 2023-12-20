---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--*****************************************************************
-- Inside of this script, you will find helper functions
--*****************************************************************

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************

local funcs = {}
-- Providing standard JSON functions
funcs.json = require('Configuration/DigitalIOManager/helper/Json')

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Create JSON list for dynamic table
---@param portType string Type of port
---@param contentA string Name of 'DigitalInput' or 'DigitalOutput' or 'Links'
---@param contentB string State of 'InputActive' or 'OutputActive' or 'TriggerEvent' or 'ListenEvent'
---@param contentC string State of 'DebounceMode' or 'ActivationMode' or 'DataInfo'
---@param contentD string State of 'DebounceValue' or 'ActivationValue'
---@param contentE string State of 'InputLogic' or 'OutputLogic'
---@param contentF string State of 'OutputMode'
---@param contentG string State of 'ModeInput' or 'ModeOutput'
---@param contentH string 'SensorStatus' of sensors measurement
---@return string jsonstring JSON string
local function createJsonList(portType, contentA, contentB, contentC, contentD, contentE, contentF, contentG, contentH)
  local orderedTable = {}
  local connectorList = {}

  if contentA ~= nil then
    for n in pairs(contentA) do
      table.insert(orderedTable, n)
    end
    table.sort(orderedTable)

    for _, value in ipairs(orderedTable) do
      if portType == 'input' then
        table.insert(connectorList, {DigitalInput = value, InputActive = contentB[value], DebounceMode = contentC[value], DebounceValue = contentD[value], InputLogic = contentE[value], ModeInput = contentG[value], SensorStatus = contentH[value]})
      elseif portType == 'output' then
        table.insert(connectorList, {DigitalOutput = value, OutputActive = contentB[value], ActivationMode = contentC[value], ActivationValue = contentD[value], OutputLogic = contentE[value], OutputMode = contentF[value], ModeOutput = contentG[value]})
      elseif portType == 'links' then
        table.insert(connectorList, {LinkNo = tostring(value), Input = contentA[value]['input'], Output = contentA[value]['output'], Delay = contentA[value]['delay']})
      elseif portType == 'forwardTrigger' then
        if contentB[value] then
          table.insert(connectorList, {FromInput = value, TriggerEvent = contentB[value], DataInfo = contentC[value]})
        end
      elseif portType == 'outputByEvent' then
        if contentB[value] then
          table.insert(connectorList, {ListenEvent = contentB[value], SetOutput = value})
        end
      end
    end
  end

  if #connectorList == 0 then
    if portType == 'input' then
      connectorList = {{DigitalInput = '-', InputActive = '-', DebounceMode = '-', DebounceValue = '-', InputLogic = '-', ModeInput = '-', SensorStatus = '-'},}
    elseif portType == 'output' then
      connectorList = {{DigitalOutput = '-', OutputActive = '-', ActivationMode = '-', ActivationValue = '-', OutputLogic = '-', OutputMode = '-', ModeOutput = '-'},}
    elseif portType == 'links' then
      connectorList = {{LinkNo = '-', Input = '-', Output = '-', Delay = '-'},}
    elseif portType == 'forwardTrigger' then
      connectorList = {{ForwardNo = '-', FromInput = '-', TriggerEvent = '-', DataInfo = '-'},}
    elseif portType == 'outputByEvent' then
      connectorList = {{TriggerNo = '-', ListenEvent = '-', SetOutput = '-'},}
    end
  end

  local jsonstring = funcs.json.encode(connectorList)
  return jsonstring
end
funcs.createJsonList = createJsonList

--- Function to convert a table into a Container object
---@param content auto[] Lua Table to convert to Container
---@return Container cont Created Container
local function convertTable2Container(content)
  local cont = Container.create()
  for key, value in pairs(content) do
    if type(value) == 'table' then
      cont:add(key, convertTable2Container(value), nil)
    else
      cont:add(key, value, nil)
    end
  end
  return cont
end
funcs.convertTable2Container = convertTable2Container

--- Function to convert a Container into a table
---@param cont Container Container to convert to Lua table
---@return auto[] data Created Lua table
local function convertContainer2Table(cont)
  local data = {}
  local containerList = Container.list(cont)
  local containerCheck = false
  if tonumber(containerList[1]) then
    containerCheck = true
  end
  for i=1, #containerList do

    local subContainer

    if containerCheck then
      subContainer = Container.get(cont, tostring(i) .. '.00')
    else
      subContainer = Container.get(cont, containerList[i])
    end
    if type(subContainer) == 'userdata' then
      if Object.getType(subContainer) == "Container" then

        if containerCheck then
          table.insert(data, convertContainer2Table(subContainer))
        else
          data[containerList[i]] = convertContainer2Table(subContainer)
        end

      else
        if containerCheck then
          table.insert(data, subContainer)
        else
          data[containerList[i]] = subContainer
        end
      end
    else
      if containerCheck then
        table.insert(data, subContainer)
      else
        data[containerList[i]] = subContainer
      end
    end
  end
  return data
end
funcs.convertContainer2Table = convertContainer2Table

--- Function to get content list out of table
---@param data string[] Table with data entries
---@return string sortedTable Sorted entries as string, internally seperated by ','
local function createContentList(data)
  local sortedTable = {}
  for key, _ in pairs(data) do
    table.insert(sortedTable, key)
  end
  table.sort(sortedTable)
  return table.concat(sortedTable, ',')
end
funcs.createContentList = createContentList

--- Function to create a list from table
---@param content string[] Table with data entries
---@return string list String list
local function createStringListBySimpleTable(content)
  local list = "["
  if #content >= 1 then
    list = list .. '"' .. content[1] .. '"'
  end
  if #content >= 2 then
    for i=2, #content do
      list = list .. ', ' .. '"' .. content[i] .. '"'
    end
  end
  list = list .. "]"
  return list
end
funcs.createStringListBySimpleTable = createStringListBySimpleTable

return funcs

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************