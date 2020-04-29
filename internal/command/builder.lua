local def = require("definitions")
local log = require("utils.log")
local getFutureEntries = require("command.completer")

local str = require("string")
local ser = require("serpent")

function buildCommand(state)
  for entries in pairs({def.read(state['context']), def.read('global')}) do

  end
end

return buildCommand


