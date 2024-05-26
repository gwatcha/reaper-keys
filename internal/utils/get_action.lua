local actions = require("definitions.actions")

---@param action_name string
---@return Action | nil
function getAction(action_name)
  return actions[action_name]
end

return getAction
