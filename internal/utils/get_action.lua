local actions = require "definitions.actions"

---@param name string
---@return Action | nil
function GetAction(name) return actions[name] end

return GetAction
