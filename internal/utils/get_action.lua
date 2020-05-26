local actions = require('definitions.actions')

function getAction(action_name)
  return actions[action_name]
end

return getAction
