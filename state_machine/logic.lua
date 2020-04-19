local logic = {}

local log = require('utils.log')
local serpent = require('serpent')

local modes = {
  normal = 0,
  selection_pending = 1,
  operator_pending = 2,
  visual = 3,
}

local display = require("display")
local definitions = require("definitions")
local dispatch = require("dispatch")
local str = require("string")

function splitIntoPrefixNumberAndCommandSequence(key_sequence)
  local prefix_number_str = str.match(key_sequence, '^[1-9][0-9]*')
  if prefix_number_str then
    local prefix_number = tonumber(prefix_number_str)
    local command_key_sequence_start = str.len(prefix_number_str) + 1
    local command_key_sequence = str.sub(key_sequence, command_key_sequence_start)
    return prefix_number, command_key_sequence
  else
    return nil, key_sequence
  end
end

function logic.tick(state, key_press)
  local new_state = state

  -- TODO make me a reaper action
  if key_press['key'] == "<esc>" then
    -- or tooLong(actions, query)
      -- or actionRet
    new_state['key_sequence'] = ""
    new_state['mode'] = modes['normal']
    return new_state
  end

  local new_key_sequence = state['key_sequence'] .. key_press['key']

  local prefix_num, command_sequence = splitIntoPrefixNumberAndCommandSequence(new_key_sequence)
  local repetitions = 1
  if prefix_num then
    repetitions = prefix_num
  end

  if state["mode"] == modes["normal"] then
    local tables_to_search =  {key_press['context'], 'global'}
    local command_types_to_search = {'actions', 'motions', 'operators'}
    local command = definitions.findCommand(command_sequence, tables_to_search, command_types_to_search)
    if command then
      log.info('Command triggered: ' .. serpent.block(command, {comment=false}))
      new_state = dispatch(command, repetitions, state)
    else
      new_state['key_sequence'] = new_key_sequence
    end
  end

  return new_state
end

return logic
