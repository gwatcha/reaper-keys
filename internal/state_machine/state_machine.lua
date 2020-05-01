local state_machine = {}

local state_interface = require('state_machine.state_interface')
local state_machine_constants = require("state_machine.constants")
local command = require("command")
local utils = require("command.utils")
local log = require('utils.log')

local ser = require("serpent")

function input(key_press)
  reaper.ClearConsole()
  log.info("input: " .. ser.line(key_press, {comment=false}))

  local state = state_interface.get()

  if state['key_sequence'] == "" then
    state['context'] = key_press['context']
  elseif state['context'] ~= key_press['context'] then
    log.info('Invalid key sequence. Next key is in different context.')
    return state_machine_constants['reset_state']
  end

  local new_state = state
  new_state["key_sequence"] = state['key_sequence'] .. key_press['key']

  local cmd = command.buildCommand(new_state)
  if cmd then
    new_state = command.executeCommand(state, cmd)
    log.info('Command triggered: ' .. utils.makeCommandDescription(cmd))
  else
    local future_entries = command.getPossibleFutureEntries(new_state)
    if not future_entries then
      log.info('Undefined key sequence: ' .. new_state['key_sequence'])
      new_state = state_machine_constants['reset_state']
    else
      log.info("Completions: " .. ser.block(future_entries, {comment=false, maxlevel=2}))
    end
  end

  log.info("new state: " .. ser.block(new_state, {comment=false}) .. "\n")
  state_interface.set(new_state)
end

return input
