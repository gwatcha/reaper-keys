local utils = require('command.utils')
local action_sequences = require('command.action_sequences')
local definitions = require('utils.definitions')
local getAction = require('utils.get_action')
local format = require('utils.format')
local log = require('utils.log')

local str = require('string')

function getActionKeyWithRegisterPostfix(key_sequence, register, entries)
  local action_name = utils.getEntryForKeySequence(key_sequence, entries)
  if action_name and not utils.isFolder(action_name) then
    if utils.checkIfActionHasOptionSet(action_name, 'registerAction') or utils.checkIfActionHasOptionSet(action_name, 'registerOptional') then
      return {action_name, register = register}
    end
  end
  return nil
end

function getActionKeyWithNumberPrefix(key_sequence, number_prefix, entries)
  local action_name = utils.getEntryForKeySequence(key_sequence, entries)
  if action_name and not utils.isFolder(action_name) then
    if utils.checkIfActionHasOptionSet(action_name, 'prefixRepetitionCount') then
      return {action_name, prefixedRepetitions = number_prefix}
    end
  end

  local key_sequence, possible_register = utils.splitLastKey(key_sequence)
  local action_key = getActionKeyWithRegisterPostfix(key_sequence, possible_register, entries)
  if action_key then
    action_key['prefixedRepetitions'] = number_prefix
    return action_key
  end

  return nil
end

function getActionKey(key_sequence, entries)
  local action_name = utils.getEntryForKeySequence(key_sequence, entries)
  if action_name and not utils.isFolder(action_name) and not utils.checkIfActionHasOptionSet(action_name, 'registerAction') then
    return action_name
  end

  local number_match, rest_of_key_sequence = utils.splitFirstMatch(key_sequence, '[1-9][0-9]*')
  if number_match then
    return getActionKeyWithNumberPrefix(rest_of_key_sequence, tonumber(number_match), entries)
  end

  local rest_of_key_sequence, possible_register = utils.splitLastKey(key_sequence)
  local action_key = getActionKeyWithRegisterPostfix(rest_of_key_sequence, possible_register, entries)
  if action_key then
    return action_key
  end

  return nil
end

function stripNextActionKeyInKeySequence(key_sequence, action_type_entries)
  if not action_type_entries then
    return nil, nil, false
  end

  local rest_of_key_sequence = ""
  local key_sequence_for_action_type = key_sequence
  while #key_sequence_for_action_type ~= 0 do
    local action_key = getActionKey(key_sequence_for_action_type, action_type_entries)
    if action_key then
      return rest_of_key_sequence, action_key, true
    end

    key_sequence_for_action_type, last_key = utils.splitLastKey(key_sequence_for_action_type)
    rest_of_key_sequence = last_key .. rest_of_key_sequence
  end

  return nil, nil, false
end

function buildCommandWithSequence(key_sequence, action_sequence, entries)
  local command = {
    action_sequence = {},
    action_keys = {},
  }

  local rest_of_key_sequence = key_sequence
  for _, action_type in pairs(action_sequence) do
    rest_of_key_sequence, action_key, found = stripNextActionKeyInKeySequence(rest_of_key_sequence, entries[action_type])
    if not found then
      return nil
    else
      table.insert(command.action_sequence, action_type)
      table.insert(command.action_keys, action_key)
    end
  end

  if #rest_of_key_sequence > 0 then
    return nil
  end

  return command
end

function buildCommand(state)
  local action_sequences = action_sequences.getPossibleActionSequences(state['context'], state['mode'])
  local entries = definitions.getPossibleEntries(state['context'])

  for _, action_sequence in pairs(action_sequences) do
    local command = buildCommandWithSequence(state['key_sequence'], action_sequence, entries)
    if command then
      command['mode'] = state['mode']
      command['context'] = state['context']
      return command
    end
  end

  return nil
end

return buildCommand
