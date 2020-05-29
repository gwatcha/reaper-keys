local utils = require('command.utils')
local regex_match_entry_types = require('command.constants').regex_match_entry_types
local sequences = require('command.sequences')
local definitions = require('utils.definitions')
local getAction = require('utils.get_action')
local log = require('utils.log')

local str = require('string')

function formatActionIdentifier(action_name, rest_of_sequence)
    if utils.checkIfActionIsRegisterAction(action_name) then
    if rest_of_sequence == "" then
      return nil
    end
    register_key, rest_of_sequence = utils.splitFirstKey(rest_of_sequence)
    return {action_name, register = register_key}, rest_of_sequence
  end
  return action_name, rest_of_sequence
end

function buildCommandWithActionSequence(key_sequence, action_sequence, entries)
  local command = {
    sequence = {},
    parts = {},
    register = nil,
  }

  local rest_of_sequence = key_sequence
  for _, action_type in pairs(action_sequence) do
    local match_regex = regex_match_entry_types[action_type]
    if match_regex then
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

        local action_name = utils.getEntryForKeySequence(sequence_for_action_type, entries[action_type])
        if action_name and not utils.isFolder(action_name) then
          action_identifier, rest_of_sequence = formatActionIdentifier(action_name, rest_of_sequence)
          if not action_identifier then
            return nil
          end

          table.insert(command.sequence, action_type)
          table.insert(command.parts, action_identifier)
          break
        end
      end
    end
  end

  if #command.sequence ~= #action_sequence or #rest_of_sequence ~= 0 then
    return nil
  end

  return command
end

function buildCommand(state)
  local action_sequences = sequences.getPossibleActionSequences(state['context'], state['mode'])
  local entries = definitions.getPossibleEntries(state['context'])

  for _, action_sequence in pairs(action_sequences) do
    local command = buildCommandWithActionSequence(state['key_sequence'], action_sequence, entries)
    if command then
      command['mode'] = state['mode']
      command['context'] = state['context']
      return command
    end
  end

  return nil
end

return buildCommand
