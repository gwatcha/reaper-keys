local logic = {}

local definitions = require("definitions")
local state_machine_definitions = require("state_machine.definitions")
local output = require("state_machine.output")
local str = require("string")

local log = require('utils.log')
local serpent = require('serpent')

local edit_modes = {
  normal = "normal",
  visual = "visual",
}

local internal_modes = {
  reset = "reset",
  motion_pending = "motion_pending",
  operator_pending = "operator_pending",
}

local valid_command_types_in_mode = {
  reset = {'actions', 'motions', 'operators'},
  motion_pending = {'motions'},
  operator_pending = {'operators'}
}

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

function logic.getCompletions(state)
  local key_sequence = state['key_sequence']

  local repetitions = 1
  local prefix_num, command_sequence = splitIntoPrefixNumberAndCommandSequence(key_sequence)
  if prefix_num then
    repetitions = prefix_num
  end

  local valid_command_types = valid_command_types_in_mode[state['internal_mode']]
  local definitions_tables = definitions.readMultiple({state['last_context'], 'global'})

  local completions = {}
  for _, definition_table in ipairs(definitions_tables) do
    for _, valid_command_type in ipairs(valid_command_types) do
      local section_completions = definitions.getCompletions(command_sequence, definition_table[valid_command_type])
      if section_completions then
        for sequence, sequence_value in pairs(section_completions) do
          if not completions[sequence] then
            found_completion = true
            completions[sequence] = sequence_value
          end
        end
      end
    end
  end

  if found_completion then
    return completions
  else
    return nil
  end
end

function logic.tick(state, key_press)
  local new_state = state

  if state['key_sequence'] == "" then
    new_state['context'] = key_press['context']
  elseif state['context'] ~= key_press['context'] then
    log.info('Invalid key sequence. Next key is in different context.')
    return state_machine_definitions['reset_state']
  end

  local new_key_sequence = state['key_sequence'] .. key_press['key']
  local repetitions = 1
  local prefix_num, command_sequence = splitIntoPrefixNumberAndCommandSequence(new_key_sequence)
  if prefix_num then
    repetitions = prefix_num
  end

  local current_completions = logic.getCompletions(state)
  if not current_completions then
    log.error('Completions for current sequence is nil, this is an unexpected state. Resetting.')
    return state_machine_definitions['reset_state']
  end

  local completion = current_completions[key_press['key']]
  if completion ~= nil and not definitions.isFolder(completion) then
      log.info('Command triggered: ' .. serpent.block(completion, {comment=false}))
      new_state = output(completion, repetitions, state)
  end

  if completion ~= nil and definitions.isFolder(completion) then
    new_state['key_sequence'] = new_key_sequence
  end

  if completion == nil then
    local next_completions = logic.getCompletions(new_state)
    if next_completions == nil then
      new_state = state_machine_definitions['reset_state']
      log.info('Undefined key sequence.')
    else
      new_state['key_sequence'] = new_key_sequence
    end
  end

  new_state['time'] = os.time()
  return new_state
end

return logic
