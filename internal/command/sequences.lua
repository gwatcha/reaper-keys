local log = require("utils.log")
local ser = require("serpent")
local utils = require("command.utils")

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

function sequences.getFunctionForCommand(command, context, mode)
  local sequences = sequence_definitions[context][mode]
  if not sequences then
    return nil
  end

  for _, sequence_function_pair in pairs(sequences) do
    local current_entry_type_sequence = sequence_function_pair[1]
    local function_for_seq = sequence_function_pair[2]
    if utils.checkIfCommandFollowsSequence(command, current_entry_type_sequence) then
      return function_for_seq
    end
  end

  return nil
end

return sequences
