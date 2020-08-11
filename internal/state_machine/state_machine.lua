local state_machine = {}

local state_interface = require('state_machine.state_interface')
local state_machine_constants = require('state_machine.constants')

local buildCommand = require('command.builder')
local handleCommand = require('command.handler')
local getPossibleFutureEntries = require('command.completer')

local log = require('utils.log')
local format = require('utils.format')
local feedback = require('gui.feedback.controller')

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

function step(state, key_press)
  local message = ""
  local new_state, err = updateWithKeyPress(state, key_press)
  if err ~= nil then
    new_state = state
    new_state['key_sequence'] = ''
    feedback.displayMessage(err)
    return new_state
  end

  log.info("New key sequence: " .. new_state['key_sequence'])
  local command = buildCommand(new_state)
  if command then
    log.trace("Command built: " .. format.block(command))
    new_state, message = handleCommand(new_state, command)
    feedback.displayMessage(message)
    return new_state
  end

  local future_entries = getPossibleFutureEntries(new_state)
  if not future_entries then
    new_state['key_sequence'] = ''
    feedback.displayMessage("Undefined key sequence")
    return new_state
  end

  local message = format.keySequence(state['key_sequence'], true)
  message = message .. "-"
  feedback.displayMessage(message)
  feedback.displayCompletions(future_entries)

  return new_state
end

function input(key_press)
  log.info("\n++++\ninput: " .. format.line(key_press))
  feedback.clear()

  local state = state_interface.get()
  local new_state = step(state, key_press)
  state_interface.set(new_state)

  feedback.displayState(state)
  feedback.update()

  log.info("new state: " .. format.block(new_state))
end

return input
