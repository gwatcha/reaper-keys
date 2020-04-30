local constants = require('state_machine.constants')
local state_interface = require('state_machine.state_interface')

local library = {}

function library.forceNormalMode()
  state_interface.set(constants['reset_state'])
  -- TODO turn off recording
end

function library.repeatLastAction()
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

function library.visualTrackMode()
end

function library.visualTimelineMode()
end

return library

