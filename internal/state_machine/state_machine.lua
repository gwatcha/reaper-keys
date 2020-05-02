local state_machine = {}

local state_interface = require('state_machine.state_interface')
local state_machine_constants = require("state_machine.constants")
local command = require("command")
local utils = require("command.utils")
local log = require('utils.log')

local ser = require("serpent")

function checkIfStatesAreSame(state1, state2)
  for k,value in pairs(state1) do
    if value ~= state2[k] then
      return false
    end
  end

  return true
end

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

  local new_key_sequence = state['key_sequence'] .. key_press['key']

  local cmd = command.buildCommand(state, new_key_sequence)
  if cmd then
    command.executeCommand(cmd, state['context'], state['mode'])
    log.info('Command triggered: ' .. utils.makeCommandDescription(cmd))
    -- internal commands may have changed the state
    if not checkIfStatesAreSame(state_interface.get(), state) then
      state = state_interface.get()
    end
    state['key_sequence'] = ""
    state['last_command'] = cmd
  else
    local future_entries = command.getPossibleFutureEntries(state, new_key_sequence)
    if not future_entries then
      log.info('Undefined key sequence: ' .. new_key_sequence)
      state = state_machine_constants['reset_state']
    else
      state['key_sequence'] = new_key_sequence
      log.info("Completions: " .. utils.printEntries(future_entries))
    end
  end

  log.info("new state: " .. ser.block(state, {comment=false}) .. "\n")
  state_interface.set(state)
end

return input
