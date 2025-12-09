local utils = require('command.utils')
local definitions = {}
local definition_tables = require"definitions.bindings"

-- this reverses the keys and values of entries
function definitions.getBindings(entries)
  local bindings = {}
  if not entries then
    return bindings
  end

  for entry_key,entry_value in pairs(entries) do
    if utils.isFolder(entry_value) then
      local folder_table = entry_value[2]
      local folder_bindings = definitions.getBindings(folder_table)

      for action_name_from_folder,binding_from_folder in pairs(folder_bindings) do
        bindings[action_name_from_folder] = entry_key .. binding_from_folder
      end
    else
      bindings[entry_value] = entry_key
    end
  end

  return bindings
end


function definitions.getAllBindings()
  local bindings = {}

  for context,context_definitions in pairs(definition_tables) do
    bindings[context] = {}

    for action_type,action_type_definitions in pairs(context_definitions) do
      bindings[context][action_type] = definitions.getBindings(action_type_definitions)
    end
  end

  return bindings
end

return definitions
