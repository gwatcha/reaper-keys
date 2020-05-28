local log = require('utils.log')
local format = require('utils.format')

local custom_actions = {}

local movement = require('custom_actions.movement')
local selection = require('custom_actions.selection')
custom_actions.move = movement
custom_actions.select = selection

function custom_actions.clearTimeSelection()
  local current_position = reaper.GetCursorPosition()
  reaper.GetSet_LoopTimeRange(true, false, current_position, current_position, false)
end


return custom_actions
