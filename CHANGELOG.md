# Changelog
All notable changes to this project will be documented in this file.

## Release 3.9.0

### New features
- Optionally track and show status of input signals to e.g. show them in UI

### Improvements
- Status of the input signal of signal links (running via cFlow) is now provided additionally via event 'OnNewFlowInputState[ENUM]'.
- Show sample screenshot in UI if module is not supported

### Bugfix
- Removed signal links were not set to SCRIPT mode

## Release 3.8.1

### Bugfix
- "selectForwardInputToEventPair" only reacts on UI selection
- "selectOutputToSetByEventPair" only reacts on UI selection

## Release 3.8.0

### Improvements
- Minor code restructure
- Using recursive helper functions to convert Container <-> Lua table
- Update to EmmyLua annotations
- Usage of lua diagnostics
- Documentation updates

### Bugfix
- Some enumeration references were missing
- Did not deregister from trigger events

## Release 3.7.0

### New features
- Function to free / block sensor ports to be used within another app / module ("block/freeSensorPort")

### Improvements
- "OnDataLoadedOnReboot" is also notified if configuration was not loaded but to show up that the module is ready

## Release 3.6.0

### Improvements
- Using internal moduleName variable to be usable in merged apps instead of _APPNAME, as this did not work with PersistentData module in merged apps.

## Release 3.5.1

### Improvements
- Naming of UI elements and adding some mouse over information texts
- Application name added to log messages
- Added enumerations
- Minor edits, documentation, log messages

### Bugfix
- UI events notified after pageLoad after 300ms instead of 100ms to not miss

## Release 3.5.0

### Improvements
- ParameterName available on UI
- Update of helper functions to support 4-dimensional tables for PersistentData
- Loading only required APIs ('LuaLoadAllEngineAPI = false') -> less time for GC needed
- Minor code edits / docu updates

## Release 3.4.0

### New features
- New 'DataInfo' editable for incoming signals
- Forwarding available signals to other modules (like CSK_DataGateway), check e.g. setInputToForwardDataInfo(), getForwardEventList

### Improvements
- Check if module is able to run on device (CROWN is available ...) at another position - UI and Serves will still be loaded now
- Prepared for all CSK user levels: Operator, Maintenance, Service, Admin
- Changed status type of user levels from string to bool
- Renamed page folder accordingly to module name

## Release 3.3.0

### New features
- Added support for userlevels, required userlevel is Maintenance

## Release 3.2.0

### New features
- GetInputState

## Release 3.1.0

### New features
- "setOutput" to set state of digital output

### Improvements
- Main features documented within the manifest --> API document
- Events to forward input signals are created dynamically (not visible in static manifest)

## Release 3.0.0

### New features
- Update handling of persistent data according to CSK_PersistentData module ver. 2.0.0

## Release 2.1.0

### Improvements
- Update DelayValue in UI onResume
- Keep latest InternalMessage (was removed OnResume)
- Update selected values in UI (Input/Output/Delay) if a link was selected
- Save parameter name to PersistentData
- Check system and API availability
- Only reset output port if activation value is NOT 0

### Bugfix
- Sometimes delay value was not updated / used correctly

## Release 2.0.0

### New features
- Individual configuration of all available sensor ports
- Possible to add links to forward signals from input to output via dynamical cFlow (optional delay possible)
- Forward incoming input signals to events (to be used e.g. from other modules)
- Configure trigger events to set output signals (to be used e.g. from other modules)
- Documentation available
- UI updated

## Release 1.0.0
- Initial commit