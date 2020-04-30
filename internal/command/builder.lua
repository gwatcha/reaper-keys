local log = require("utils.log")
local ser = require("serpent")
local utils = require("command.utils")
local sequences = require("command.sequences")
local definitions = require("utils.definitions")

local str = require("string")

function buildCommandWithActionSequence(key_sequence, action_sequence, entries)
  local command = {}

  local rest_of_sequence = key_sequence
  for _, action_type in pairs(action_sequence) do
    if not entries[action_type] then
      return nil
    end

    local sequence_for_entry_type = ""
    while #rest_of_sequence ~= 0 do
      first_key, rest_of_sequence = utils.splitFirstKey(rest_of_sequence)
      sequence_for_entry_type = sequence_for_entry_type .. first_key

      local entry = utils.getEntryForKeySequence(sequence_for_entry_type, entries[action_type])
      if entry and not utils.isFolder(entry) then
        command[action_type] = entry
        break
      end
    end
  end

  if utils.checkIfCommandHasActionSequence(command, action_sequence) then
    return command
  end

  return nil
end

function buildCommand(state)
  local action_sequences = sequences.getPossibleActionSequences(state['context'], state['mode'])
  local entries = definitions.getPossibleEntries(state['context'])

  for _, action_sequence in pairs(action_sequences) do
    local command = buildCommandWithActionSequence(state['key_sequence'], action_sequence, entries)
    if command then
      return command
    end
  end

  return nil
end

return buildCommand


