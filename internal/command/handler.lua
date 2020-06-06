local state_interface = require('state_machine.state_interface')
local log = require('utils.log')
local saved = require('saved')
local utils = require('command.utils')
local format = require('utils.format')
local meta_command = require('command.meta_command')
local executeCommand = require('command.executor')
local config = require('definitions.config')

function utils.qualifiesAsRepeatableCommand(command)
  for _,action_type in ipairs(command.sequence) do
    for _,action_type_match in ipairs(config.repeatable_sequences_match) do
      if action_type:find(action_type_match) then
        return true
      end
    end
  end
  return false
end

function handleCommand(state, command)
  reaper.Undo_BeginBlock()
  local new_state = state

  if meta_command.isMetaCommand(command) then
    new_state = meta_command.executeMetaCommand(state, command)
  else
    executeCommand(command)
    -- internal commands may have changed the state
    if not state_interface.checkIfConsistentState(state) then
      new_state = state_interface.get()
    end

    if utils.qualifiesAsRepeatableCommand(command) then
      new_state['last_command'] = command
    end

    if new_state['macro_recording'] then
      saved.append('macros', state['macro_register'], command)
    end

    new_state['key_sequence'] = ""
  end

  reaper.Undo_EndBlock('reaper-keys: ' .. format.commandDescription(command), 1)
  local command_description = format.commandDescription(command)
  return new_state, format.userInfo(new_state, command_description)
end

return handleCommand
