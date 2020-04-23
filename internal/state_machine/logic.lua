local logic = {}

local log = require('utils.log')
local serpent = require('serpent')

local modes = {
  normal = 0,
  motion_pending = 1,
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

function findCommand(command_sequence, definitions_tables, valid_command_types)
  for _, definition_table in ipairs(definitions_tables) do
    for _, valid_command_type in ipairs(valid_command_types) do
      local command = definitions.findCommand(command_sequence, definition_table[valid_command_type])
      if command then
        return command
      end
    end
  end

  return nil
end

function getCompletions(command_sequence, definitions_tables, valid_command_types)
    local completions = {}
    local found_completion = false
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
  local new_key_sequence = state['key_sequence'] .. key_press['key']

  local repetitions = 1
  local prefix_num, command_sequence = splitIntoPrefixNumberAndCommandSequence(new_key_sequence)
  if prefix_num then
    repetitions = prefix_num
  end

  local valid_command_types = {}
  if state["mode"] == modes["normal"] or state["mode"] == modes["visual"] then
    valid_command_types = {'actions', 'motions', 'operators'}
  elseif state["mode"] == modes["motion_pending"] then
    valid_command_types = {'motions'}
  end

  local definitions_tables = definitions.readMultiple({key_press['context'], 'global'})

  local new_state = state

  local command = findCommand(command_sequence, definitions_tables, valid_command_types)
  if command then
    log.info('Command triggered: ' .. serpent.block(command, {comment=false}))
    new_state = dispatch(command, repetitions, state)
  else
    local completions = getCompletions(command_sequence, definitions_tables, valid_command_types)
    if completions then
      new_state['key_sequence'] = new_key_sequence
      new_state['in_progress'] = true
      -- log.trace('Completions: ' .. serpent.block(completions, {comment=false}))
    else
      new_state['key_sequence'] = ""
      new_state['in_progress'] = false
      log.info('Invalid key sequence.')
    end
  end

  return new_state
end

return logic
