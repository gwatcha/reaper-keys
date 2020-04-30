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

function getPossibleSequenceFunctionPairs(context, mode)
  local context_sequences = sequence_definitions[context][mode]
  local global_sequences  = sequence_definitions['global'][mode]

  local sequence_function_pairs = {}
  for _, sequence_list in pairs({context_sequences, global_sequences}) do
    for _, sequence_function_pair in ipairs(sequence_list) do
      table.insert(sequence_function_pairs, sequence_function_pair)
    end
  end

  return sequence_function_pairs
end


function sequences.getPossibleActionSequences(context, mode)
  local sequence_function_pairs = getPossibleSequenceFunctionPairs(context, mode)

  local action_sequences = {}
  for _, sequence_function_pair in ipairs(sequence_function_pairs) do
    local action_sequence = sequence_function_pair[1]
    table.insert(action_sequences, action_sequence)
  end

  return action_sequences
end

function sequences.getFunctionForCommand(command, context, mode)
  local sequence_function_pairs = getPossibleSequenceFunctionPairs(context, mode)

  action_sequence = {}
  for _, sequence_function_pair in ipairs(sequence_function_pairs) do
    local action_sequence = sequence_function_pair[1]
    if utils.checkIfCommandHasActionSequence(command, action_sequence) then
      return sequence_function_pair[2]
    end
  end

  return nil
end

return sequences
