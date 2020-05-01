local log = require("utils.log")
local ser = require("serpent")
local utils = require("command.utils")
local regex_match_entry_types = require("command.definitions.regex_match_entry_types")
local sequences = require("command.sequences")
local definitions = require("utils.definitions")

local str = require("string")

function buildCommandWithActionSequence(key_sequence, action_sequence, entries)
  local command = {
    sequence = {},
    parts = {},
  }

  local rest_of_sequence = key_sequence
  for _, action_type in pairs(action_sequence) do
    if regex_match_entry_types[action_type] then
      local match_regex = regex_match_entry_types[action_type]
      match, rest_of_sequence = utils.splitFirstMatch(rest_of_sequence, match_regex)
      if match then
        table.insert(command.sequence, action_type)
        table.insert(command.parts, match)
      else
        return nil
      end
    else
      if not entries[action_type] then return nil end
      local sequence_for_action_type = ""
      while #rest_of_sequence ~= 0 do
        first_key, rest_of_sequence = utils.splitFirstKey(rest_of_sequence)
        sequence_for_action_type = sequence_for_action_type .. first_key

        local entry = utils.getEntryForKeySequence(sequence_for_action_type, entries[action_type])
        if entry and not utils.isFolder(entry) then
          table.insert(command.sequence, action_type)
          table.insert(command.parts, entry)
          break
        end
      end
    end
  end

  if #command.sequence ~= #action_sequence then
    return nil
  end

  log.info("made cmd: " .. ser.block(command))

  return command
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
