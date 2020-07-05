local state_machine = {}

local state_interface = require('state_machine.state_interface')
local state_machine_constants = require('state_machine.constants')

local buildCommand = require('command.builder')
local handleCommand = require('command.handler')
local getPossibleFutureEntries = require('command.completer')

local log = require('utils.log')
local format = require('utils.format')

function updateWithKeyPress(state, key_press)
  local new_state = state
  if state['key_sequence'] == "" then
    new_state['context'] = key_press['context']
  elseif state['context'] ~= key_press['context'] then
    return nil, 'Undefined key sequence. Next key is in different context.'
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
    new_state['key_sequence'] = ''
    message = format.userInfo(new_state, err)
  else
    log.info("New key sequence: " .. new_state['key_sequence'])
    local command = buildCommand(new_state)
    if command then
      log.trace("Command built: " .. format.block(command))
      new_state, message = handleCommand(new_state, command)
    else
      local future_entries = getPossibleFutureEntries(new_state)
      if not future_entries then
        new_state['key_sequence'] = ''
        message = format.userInfo(state, "Undefined key sequence")
      else
        message = format.userInfoWithCompletions(new_state, future_entries)
      end
    end
  end

  log.user(message)
  log.user("\n")
  log.info("new state: " .. format.block(new_state))

  state_interface.set(new_state)
end

return input
