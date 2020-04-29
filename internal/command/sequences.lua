local log = require("utils.log")
local ser = require("serpent")

local sequences = {}

local sequence_definitions = {
  global = {
    normal = require('command.definitions.global.normal'),
    visual_timeline = require('command.definitions.global.visual_timeline'),
  },
  main = {
    normal = require('command.definitions.main.normal'),
    visual_track = require('command.definitions.main.visual_track'),
  },
  midi = {},
}

function sequences.getPossibleSequences(context, mode)
  log.info(context)
  local sequences = sequence_definitions[context][mode]
  if not sequences then
    return nil
  end

  local entry_type_sequences = {}
  for _, sequence_function_pair in pairs(sequences) do
    local current_entry_type_sequence = sequence_function_pair[1]
    table.insert(entry_type_sequences, current_entry_type_sequence)
  end

  return entry_type_sequences
end

function sequences.getFunctionForEntryTypeSequence(entry_type_sequence, context, mode)
  local sequences = sequence_definitions[context][mode]
  if not sequences then
    return nil
  end

  for _, sequence_function_pair in pairs(sequences) do

    local current_entry_type_sequence = seq_function_pair[1]
    local function_for_seq = sequence_function_pair[2]

    local length_of_sequence = table.maxn(current_entry_type_sequence)
    if current_length_of_sequence == length_of_sequence then
      local match = true
      for i=1, length_of_sequence, 1 do
        if sequence[i] ~= current_entry_type_sequence[i] then
          match = false
        end
      end

      if match then
        return function_for_seq
      end
    end
  end

  return nil
end

return sequences
