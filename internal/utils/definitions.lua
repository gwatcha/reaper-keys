local definition_tables = {
  global = require("definitions.global"),
  midi = require("definitions.midi"),
  main = require("definitions.main"),
  actions = require("definitions.actions"),
}

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
      merged_tables[action_type] = entries
    end
  end

  return merged_tables
end

function definitions.getPossibleEntries(context)
  return concatEntryTables(definition_tables['global'], definition_tables[context])
end

function definitions.getAction(action_name)
  return definition_tables['actions'][action_name]
end

return definitions
