local utils = require('command.utils')

local definitions = {}


function concatEntryTables(t1,t2)
  local merged_tables = {}
  for action_type, entries in pairs(t1) do
    merged_tables[action_type] = entries

    if t2[action_type] then
      for key_sequence,action in pairs(t2[action_type]) do
        merged_tables[action_type][key_sequence] = action
      end
    end
  end

  for action_type, entries in pairs(t2) do
    if not merged_tables[action_type] then
      merged_tables[action_type] = {}
      for key_sequence,action in pairs(entries) do
        merged_tables[action_type][key_sequence] = action
      end
    end
  end

  return merged_tables
end


local user_definitions = require('definitions.bindings')
local definition_tables = {
  global = concatEntryTables(require('definitions.defaults.global'), user_definitions.global ),
  main = concatEntryTables(require('definitions.defaults.main'), user_definitions.main ),
  midi = concatEntryTables(require('definitions.defaults.midi'), user_definitions.midi ),
}

function definitions.getPossibleEntries(context)
  local merged_table = {}
  merged_table = concatEntryTables(merged_table, definition_tables['global'])
  merged_table = concatEntryTables(merged_table, definition_tables[context])
  return merged_table
end

-- this reverses the keys and values by 'extracting' from folders
function definitions.getBindings(entries)
  local bindings = {}
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

  -- make suer user definitions are prioritized
  local user_bindings = {}
  for context,context_definitions in pairs(user_definitions) do
    user_bindings[context] = {}

    for action_type,action_type_definitions in pairs(context_definitions) do
      local bindings_for_action_type = definitions.getBindings(action_type_definitions)

      if not bindings[context][action_type] then
        bindings[context][action_type] = {}
      end
      for k,v in pairs(bindings_for_action_type) do
        bindings[context][action_type][k] = v
      end
    end
  end

  return bindings
end

function definitions.getAllEntries()
  return definition_tables
end

return definitions
