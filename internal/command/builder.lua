local def = require("definitions")
local log = require("utils.log")
local utils = require("command.utils")
local sequences = require("command.sequences")

local str = require("string")
local ser = require("serpent")

function buildCommandFollowingSequence(key_sequence, entry_type_sequence, entries)
  local command = {}

  local rest_of_sequence = key_sequence
  for _, entry_type in pairs(entry_type_sequence) do
    if not entries[entry_type] then
      return nil
    end

    local sequence_for_entry_type = ""
    while #rest_of_sequence ~= 0 do
      first_key, rest_of_sequence = utils.splitFirstKey(rest_of_sequence)
      sequence_for_entry_type = sequence_for_entry_type .. first_key

      local entry = utils.getEntryForKeySequence(sequence_for_entry_type, entries[entry_type])
      if entry then
        command[entry_type] = entry
        break
      end
    end
  end

  if utils.checkIfCommandFollowsSequence(command, entry_type_sequence) then
    return command
  end

  return nil
end

function buildCommand(state)
  local context_sequences = sequences.getPossibleSequences(state['context'], state['mode'])
  local global_sequences = sequences.getPossibleSequences('global', state['mode'])

  local future_entries = {}
  local future_entry_exists = false
  for _, entries in pairs({def.read(state['context']), def.read('global')}) do
    for _, possible_entry_type_sequences in pairs({context_sequences, global_sequences}) do
      for _, possible_entry_type_sequence in pairs(possible_entry_type_sequences) do
        local command = buildCommandFollowingSequence(state['key_sequence'], possible_entry_type_sequence, entries)
        if command then
          return command
        end
      end
    end
  end

  return nil
end

return buildCommand


