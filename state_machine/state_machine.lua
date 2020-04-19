local state_machine = {}

local log = require('utils/log')

local serpent = require("serpent")

state_interface = require('state_machine.state_interface')
logic = require('state_machine.logic')

function state_machine.input(key_press)
  log.info("input: " .. serpent.line(key_press, {comment=false}))

  state = state_interface.get()

  new_state = logic.tick(state, key_press)
  log.trace("new state: " .. serpent.block(new_state, {comment=false}) .. "\n")

  state_interface.set(new_state)
end

return state_machine
