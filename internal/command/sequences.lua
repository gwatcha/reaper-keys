local log = require("utils.log")
local ser = require("serpent")
local utils = require("command.utils")

local sequences = {}

local sequence_definitions = {
  global = require('command.sequence_functions.global'),
  main = require('command.sequence_functions.main'),
  midi = require('command.sequence_functions.midi'),
}

function concatTables(...) 
  local t = {}
  for n = 1,select("#",...) do
    local arg = select(n,...)
    if type(arg)=="table" then
      for _,v in ipairs(arg) do
        t[#t+1] = v
      end
    else
      t[#t+1] = arg
    end
  end
  return t
end

function getPossibleSequenceFunctionPairs(context, mode)
  local possible_sequence_function_pairs = concatTables(
    sequence_definitions[context][mode],
    sequence_definitions[context]['all_modes'],
    sequence_definitions['global'][mode],
    sequence_definitions['global']['all_modes']
  )

  return possible_sequence_function_pairs
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

function checkIfSequencesAreEqual(seq1, seq2)
  if #seq1 ~= #seq2 then return false end
  for i=1,#seq1 do
    if seq1[i] ~= seq2[i] then
      return false
    end
  end

  return true
end

function sequences.getFunctionForSequence(sequence, context, mode)
  local sequence_function_pairs = getPossibleSequenceFunctionPairs(context, mode)

  for _, sequence_function_pair in ipairs(sequence_function_pairs) do
    local action_sequence = sequence_function_pair[1]
    if checkIfSequencesAreEqual(sequence, action_sequence) then
      return sequence_function_pair[2]
    end
  end

  return nil
end

return sequences
