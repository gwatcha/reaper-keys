local actions = require "definitions.actions"

---@param name string
---@return Action | nil
function getAction(name) return actions[name] end

return getAction
