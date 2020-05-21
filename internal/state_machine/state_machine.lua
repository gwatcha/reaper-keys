local state_machine = {}

local state_interface = require('state_machine.state_interface')
local state_functions = require('state_machine.state_functions')
local state_machine_constants = require("state_machine.constants")
local meta_command = require("state_machine.meta_command")

local executor = require("command.executor")
local buildCommand = require("command.builder")
local getPossibleFutureEntries = require("command.completer")
local utils = require("command.utils")

local saved = require('saved')
local log = require('utils.log')
local format = require("utils.format")

function handleCommand(state, command)
  local new_state = state

  if meta_command.isMetaCommand(command) then
    new_state = meta_command.executeMetaCommand(state, command)
  else
    if state['macro_recording'] then
      saved.macros.append(state['macro_register'], command)
    end
    executor.executeCommand(command)
    -- internal commands may have changed the state
    if not state_functions.checkIfConsistentState(state) then
      new_state = state_interface.get()
    end

    new_state['last_command'] = command
    new_state['key_sequence'] = ""
  end

  local command_description = utils.makeCommandDescription(command)
  return new_state, format.userInfo(new_state, command_description)
end

function updateWithKeyPress(state, key_press)
  local new_state = state
  local error_message = nil
  if state['key_sequence'] == "" then
    new_state['context'] = key_press['context']
  elseif state['context'] ~= key_press['context'] then
    err = 'Undefined key sequence. Next key is in different context.'
    return nil, err
  end

  local new_key_sequence = state['key_sequence'] .. key_press['key']
  new_state['key_sequence'] = new_key_sequence

  return new_state, nil
end

function input(key_press)
  reaper.ClearConsole()
  log.user("")

  local state = state_interface.get()

  local message = ""
  local new_state, err = updateWithKeyPress(state, key_press)
  if err ~= nil then
    new_state = state_machine_constants['reset_state']
    message = format.userInfo(new_state, err)
  else
    local command = buildCommand(new_state)
    if command then
      log.trace("Command built: " .. format.block(command))
      new_state, message = handleCommand(new_state, command)
    else
      local future_entries = getPossibleFutureEntries(new_state)
      if not future_entries then
        new_state, message = state_machine_constants['reset_state'], format.userInfo(state, "Undefined key sequence")
      else
        message = format.userInfoWithCompletions(new_state, future_entries)
      end
    end
  end

  log.user(message)
  log.info("new state: " .. format.block(new_state))

  state_interface.set(new_state)
end

return input
