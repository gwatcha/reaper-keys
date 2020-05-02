local constants = require('state_machine.constants')
local state_functions = require('state_machine.state_functions')
local log = require('utils.log')

local library = {}

function library.resetToNormal()
  state_functions.resetToNormal()
end

function library.openConfig()
end

function library.pasteRegister()
end

function library.playMacro()
end

function library.recordMacro()
end

function library.saveFxChain()
end

function library.toggleVisualTrackMode()
  state_functions.toggleMode('visual_track')
end

function library.toggleVisualTimelineMode()
  log.info("h")
  state_functions.toggleMode('visual_timeline')
end

return library

