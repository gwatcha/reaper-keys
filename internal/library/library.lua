local constants = require('state_machine.constants')
local saved = require('saved')
local state_functions = require('state_machine.state_functions')
local log = require('utils.log')

local library = {
  register_actions = {}
}

function library.resetToNormal()
  state_functions.resetToNormal()
end

function library.openConfig()
end

function library.register_actions.pasteRegister(register)
end

function library.register_actions.saveFxChain(register)
end

function library.saveFxChain()
end

function library.toggleVisualTrackMode()
  state_functions.toggleMode('visual_track')
end

function library.toggleVisualTimelineMode()
  state_functions.toggleMode('visual_timeline')
end

function library.switchTimelineSelectionSide()
  local go_to_start_of_selection = 40630
  local go_to_end_of_selection = 40631
  if state_functions.getTimelineSelectionSide() == 'right' then
    reaper.Main_OnCommand(go_to_start_of_selection, 0)
    state_functions.setTimelineSelectionSide('left')
  else
    reaper.Main_OnCommand(go_to_end_of_selection, 0)
    state_functions.setTimelineSelectionSide('right')
  end
end

return library

