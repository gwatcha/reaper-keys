local actions = require('definitions.defaults.actions')
local user_actions = require('definitions.actions')
for action_name,action_value in pairs(user_actions) do
  actions[action_name] = action_value
end

function getAction(action_name)
  return actions[action_name]
end

return getAction
