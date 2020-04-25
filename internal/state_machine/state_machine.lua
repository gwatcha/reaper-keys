local state_machine = {}

local state_interface = require('state_machine.state_interface')
local logic = require('state_machine.logic')

local log = require('utils.log')
local serpent = require("serpent")

function state_machine.input(key_press)
  log.info("input: " .. serpent.line(key_press, {comment=false}))

  local state = state_interface.get()

  local new_state = logic.tick(state, key_press)
  log.trace("new state: " .. serpent.block(new_state, {comment=false}) .. "\n")

  state_interface.set(new_state)
end

return state_machine
