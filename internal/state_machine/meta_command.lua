local meta_command = {}

local executor = require("command.executor")
local utils = require("command.utils")
local format = require("utils.format")
local saved = require('saved')

local log = require('utils.log')

function executeMultipleCommandOrMetaCommands(state, command, macro_commands, repetitions)
  reaper.Undo_BeginBlock()
  for i=1,repetitions do
    for i,macro_command in pairs(macro_commands) do
      if meta_command.isMetaCommand(macro_command) then
        meta_command.executeMetaCommand(state, macro_command)
      else
        executor.dispatchCommand(macro_command, state['context'], state['mode'])
      end
    end
  end

  reaper.Undo_EndBlock('reaper-keys: ' .. repetitions .. " * " .. utils.makeCommandDescription(command), 1)
end

function executeCommandOrMetaCommand(state, command, repetitions)
  if meta_command.isMetaCommand(command) then
    reaper.Undo_BeginBlock()
    for i=1,repetitions do
      meta_command.executeMetaCommand(state, command)
    end
    reaper.Undo_EndBlock('reaper-keys: ' .. repetitions .. " * " .. utils.makeCommandDescription(command), 1)
  else
    executor.executeCommandMultipleTimes(command, repetitions)
  end
end

local commands = {
  ["PlayMacro"] = function(state, command)
    local repetitions = 1
    if utils.getActionTypeValueInCommand(command, 'number') then
      repetitions = utils.getActionTypeValueInCommand(command, 'number')
    end

    local register = utils.getActionTypeValueInCommand(command, 'register_location')
    if not register then
      -- skip, we have probably triggered before the user has specified a register
      return state
    end

    local macro_commands = saved.macros.get(register)
    if macro_commands then
      executeMultipleCommandOrMetaCommands(state, command, macro_commands, repetitions)
      if state['macro_recording'] then
        saved.macros.append(state['macro_register'], command)
      end
    end

    local new_state = state
    new_state['last_command'] = command
    new_state['key_sequence'] = ""
    return new_state
  end,
  ["RecordMacro"] = function(state, command)
    if not state['macro_recording'] then
      local register = utils.getActionTypeValueInCommand(command, 'register_location')
      if not register then
        -- skip, we have probably triggered before the user has specified a register
        return state
      end

      saved.macros.clear(register)
      state['macro_register'] = register
      state['macro_recording'] = true
    else
      state['macro_recording'] = false
    end

    local new_state = state
    new_state['last_command'] = command
    new_state['key_sequence'] = ""
    return new_state
  end,
  ["RepeatLastCommand"] = function(state, command)
    local repetitions = 1
    if utils.getActionTypeValueInCommand(command, 'number') then
      repetitions = utils.getActionTypeValueInCommand(command, 'number')
    end

    local last_command = state['last_command']
    executeCommandOrMetaCommand(state, last_command, repetitions)
    if state['macro_recording'] then
      saved.macros.append(state['macro_register'], state['last_command'])
    end

    local new_state = state
    new_state['key_sequence'] = ""
    return new_state
  end
}

function meta_command.isMetaCommand(command)
  for _, action_type in pairs(command.sequence) do
    if action_type == "meta_command" then
      return true
    end
  end
  return false
end

function meta_command.executeMetaCommand(state, command)
  local meta_command_name = ""
  for i,action_type in pairs(command.sequence) do
    if action_type == 'meta_command' then
      meta_command_name = command.parts[i]
    end
  end

  if not commands[meta_command_name] then
    log.fatal("Unknown meta command: " .. meta_command_name)
    log.fatal("Available meta commands are: " .. format.line(commands))
  end

  local new_state = commands[meta_command_name](state, command)
  return new_state
end

return meta_command
