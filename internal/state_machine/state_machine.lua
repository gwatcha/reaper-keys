local state_machine = {}

local state_interface = require('state_machine.state_interface')
local state_functions = require('state_machine.state_functions')
local saved = require('saved')
local state_machine_constants = require("state_machine.constants")
local meta_command = require("state_machine.meta_command")
local command = require("command")
local utils = require("command.utils")
local log = require('utils.log')
local ser = require("serpent")

function input(key_press)
  reaper.ClearConsole()
  log.trace("input: " .. ser.line(key_press, {comment=false}))

  local state = state_interface.get()

  if state['key_sequence'] == "" then
    state['context'] = key_press['context']
  elseif state['context'] ~= key_press['context'] then
    log.info('Invalid key sequence. Next key is in different context.')
    return state_machine_constants['reset_state']
  end

  local new_key_sequence = state['key_sequence'] .. key_press['key']

  local cmd = command.buildCommand(state, new_key_sequence)
  local sequence_defined = true
  if cmd then
    if meta_command.isMetaCommand(cmd) then
      state['key_sequence'] = new_key_sequence
      state = meta_command.executeMetaCommand(state, cmd)
    else
      if state['macro_recording'] then
        saved.macros.append(state['macro_register'], cmd)
      end
      command.executeCommand(cmd, state['context'], state['mode'])
      -- internal commands may have changed the state
      if not state_functions.checkIfConsistentState(state) then
        state = state_interface.get()
      end

      state['last_command'] = cmd
      state['key_sequence'] = ""
    end
  else
    future_entries = command.getPossibleFutureEntries(state, new_key_sequence)
    if not future_entries then
      sequence_defined = false
      state = state_machine_constants['reset_state']
    else
      state['key_sequence'] = new_key_sequence
      if not tonumber(new_key_sequence:sub(#new_key_sequence)) then
        log.user(utils.printCompletions(future_entries))
      end
    end
  end

  log.user(utils.printUserInfo(state, sequence_defined) .. "\n")
  log.info("new state: " .. ser.block(state, {comment=false}) .. "\n")
  state_interface.set(state)
end

return input
