--[[
++============================================================================++
||                                                                            ||
||  Inside of this script, you will find helper functions.                    ||
||                                                                            ||
++============================================================================++
]]--
---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--[[ ********************************************************************** ]]--
--[[ ************************ Start of Global Scope *********************** ]]--
--[[ ********************************************************************** ]]--

local funcs = {}
-- Providing access to standard JSON functions.
funcs.json = require( "Configuration/DigitalIOManager/helper/Json" )

--[[ ********************************************************************** ]]--
--[[ ************************* End of Global Scope ************************ ]]--
--[[ ********************************************************************** ]]--

--[[ :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: ]]--
--[[ :::::::::::::::::: Start of Function and Event Scope ::::::::::::::::: ]]--
--[[ :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: ]]--

--[[ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ]]--

--- Create JSON list for dynamic table.
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
      if portType == "input" then
        table.insert(connectorList, {DigitalInput = value, InputActive = contentB[value], DebounceMode = contentC[value], DebounceValue = contentD[value], InputLogic = contentE[value], ModeInput = contentG[value], SensorStatus = contentH[value]})
      elseif portType == "output" then
        table.insert(connectorList, {DigitalOutput = value, OutputActive = contentB[value], ActivationMode = contentC[value], ActivationValue = contentD[value], OutputLogic = contentE[value], OutputMode = contentF[value], ModeOutput = contentG[value]})
      elseif portType == "links" then
        table.insert(connectorList, {LinkNo = tostring(value), Input = contentA[value]["input"], Output = contentA[value]["output"], Delay = contentA[value]["delay"]})
      elseif portType == "forwardTrigger" then
        if contentB[value] ~= nil then
          table.insert(connectorList, {FromInput = value, TriggerEvent = contentB[value], DataInfo = contentC[value]})
        end
      elseif portType == "outputByEvent" then
        if contentB[value] ~= nil then
          table.insert(connectorList, {ListenEvent = contentB[value], SetOutput = value})
        end
      end
    end
  end

  if #connectorList == 0 then
    if portType == "input" then
      connectorList = {{DigitalInput = "-", InputActive = "-", DebounceMode = "-", DebounceValue = "-", InputLogic = "-", ModeInput = "-", SensorStatus = "-"},}
    elseif portType == "output" then
      connectorList = {{DigitalOutput = "-", OutputActive = "-", ActivationMode = "-", ActivationValue = "-", OutputLogic = "-", OutputMode = "-", ModeOutput = "-"},}
    elseif portType == "links" then
      connectorList = {{LinkNo = "-", Input = "-", Output = "-", Delay = "-"},}
    elseif portType == "forwardTrigger" then
      connectorList = {{ForwardNo = "-", FromInput = "-", TriggerEvent = "-", DataInfo = "-"},}
    elseif portType == "outputByEvent" then
      connectorList = {{TriggerNo = "-", ListenEvent = "-", SetOutput = "-"},}
    end
  end

  local jsonString = funcs.json.encode(connectorList)

  return jsonString
end
funcs.createJsonList = createJsonList

--[[ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ]]--
--- Convert a table into a 'Container' object.
---@param inContent auto[] Lua table to convert to 'Container'
---@return Container outContainer Created 'Container'
local function convertTable2Container(inContent)
  local outContainer = Container.create()
  for key, value in pairs(inContent) do
    if type(value) == "table" then
      outContainer:add(key, convertTable2Container(value), nil)
    else
      outContainer:add(key, value, nil)
    end
  end

  return outContainer
end
funcs.convertTable2Container = convertTable2Container


--[[ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ]]--
--- Convert a 'Container' object into a table.
---@param inContainer Container 'Container' to convert to Lua table
---@return auto[] outData Created Lua table
local function convertContainer2Table(inContainer)
  local outData = {}
  local containerList = Container.list(inContainer)
  local containerCheck = false
  if tonumber(containerList[1]) ~= nil then
    containerCheck = true
  end
  for i = 1, #containerList, 1 do
    local subContainer

    if containerCheck == true then
      subContainer = Container.get(inContainer, tostring(i) .. ".00")
    else
      subContainer = Container.get(inContainer, containerList[i])
    end
    if type(subContainer) == "userdata" then
      if Object.getType(subContainer) == "Container" then

        if containerCheck == true then
          table.insert(outData, convertContainer2Table(subContainer))
        else
          outData[containerList[i]] = convertContainer2Table(subContainer)
        end

      else
        if containerCheck == true then
          table.insert(outData, subContainer)
        else
          outData[containerList[i]] = subContainer
        end
      end
    else
      if containerCheck == true then
        table.insert(outData, subContainer)
      else
        outData[containerList[i]] = subContainer
      end
    end
  end

  return outData
end
funcs.convertContainer2Table = convertContainer2Table

--[[ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ]]--
--- Get a content list out of a table.
---@param inData string[] Table with data entries
---@return string sortedTable Sorted entries as string, internally separated by ','
local function createContentList(inData)
  local sortedTable = {}
  for key, _ in pairs(inData) do
    table.insert(sortedTable, key)
  end
  table.sort(sortedTable)

  return table.concat( sortedTable, "," )
end
funcs.createContentList = createContentList

--[[ ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ ]]--
--- Create a string of all elements of a table.
---@param inData string[] Table with data entries
---@return string list List of data entries
local function createStringListBySimpleTable(inData)
  if inData ~= nil then
    local list = "["
    if #inData >= 1 then
      list = list .. '"' .. inData[1] .. '"'
    end
    if #inData >= 2 then
      for i=2, #inData, 1 do
        list = list .. ', ' .. '"' .. inData[i] .. '"'
      end
    end
    list = list .. "]"

    return list
  else

    return ''
  end
end
funcs.createStringListBySimpleTable = createStringListBySimpleTable

return funcs

--[[ :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: ]]--
--[[ ::::::::::::::::::: End of Function and Event Scope :::::::::::::::::: ]]--
--[[ :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: ]]--
