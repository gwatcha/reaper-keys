local state_machine = {}

local state_interface = require('state_machine.state_interface')
local state_functions = require('state_machine.state_functions')
local saved = require('saved')
local state_machine_constants = require("state_machine.constants")
local command = require("command")
local utils = require("command.utils")
local saved = require("saved")
local log = require('utils.log')

local ser = require("serpent")

local special_commands = {
  ["PlayMacro"] = function(state, cmd)
    -- FIXME I don't like this library returns through state
    -- though i can't think of another way without circular deps
    local macro_commands = saved.macros.get(register)
    state_functions.triggerMacroCommands(macro_commands)
    command.executeMacroCommands(macro_commands, state['context'], state['mode'], 'PlayMacro')
    if state['macro_recording'] then
      saved.macros.append(state['macro_register'], cmd)
    end
  end,
  ["RecordMacro"] = function(state, cmd)
    local register = cmd.parts[2]
    if not state_functions.getIsMacroRecording() then
      saved.macros.clear(register)
      state_functions.startMacroRecording(register)
    else
      state_functions.endMacroRecording()
    end
  end,
  ["RepeatLastCommand"] = function(state, cmd)
    command.executeCommand(state['last_command'], state['context'], state['mode'])
    if state['macro_recording'] then
      saved.macros.append(state['macro_register'], state['last_command'])
    end
  end
}

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
    log.info('Command triggered: ' .. utils.makeCommandDescription(cmd))
    if special_commands[cmd.parts[1]] then
      state = special_commands[cmd.parts[1]](state, cmd)
    else
      if state['macro_recording'] then
        saved.macros.append(state['macro_register'], cmd)
      end
      command.executeCommand(cmd, state['context'], state['mode'])
      -- internal commands may have changed the state
      if not state_functions.checkIfConsistentState(state) then
        state = state_interface.get()
      end
    end

    state['last_command'] = cmd
    state['key_sequence'] = ""
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
  state_interface.set(state)
end

return input
