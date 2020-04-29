local state_machine_definitions = require('state_machine.definitions')
local log = require('utils.log')

function makeCommandDescription(command)
  local desc = ""
  for entry in command['entry_values'] do
    local command_name = entry[2]
    if command_name then
      desc = desc + command_name + " "
    end
  end

  return desc
end

function executeCommand(state, command)
  local entry_types = command['entry_types']
  local entry_values = command['entry_values']

  if table.maxn(entry_types) ~= table.maxn(entry_values) then
    log.error('Number of entry types (' + table.maxn(entry_type) + ') does not equal number of entry values (' + table.maxn(entry_value) + ')')
    return state_machine_definitions['reset_state']
  end

  local functionForCommand = getFunctionForEntryTypeSequence(entry_types, state['context'], state['mode'])
  if functionForCommand then
    reaper.Undo_BeginBlock()
    local new_state = functionForCommand(state, unpack(entry_values))
    reaper.Undo_EndBlock('reaper-keys: ' .. makeCommandDescription(command), 0)
    return new_state
  end

  log.error('Did not find an associated command function to execute for this command!')
  return state_machine_definitions['reset_state']
end

return executeCommand
