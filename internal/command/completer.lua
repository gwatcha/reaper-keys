local sequences = require('command.sequences')
local utils = require('command.utils')
local definitions = require('utils.definitions')
local command_constants = require('command.constants')
local log = require('utils.log')
local format = require('utils.format')

local regex_match_entry_types = command_constants.regex_match_entry_types

function stripBegginingKeys(full_key_sequence, start_key_sequence)
  if #start_key_sequence >= #full_key_sequence then
    return nil
  end

  rest_of_sequence = ""
  for i=1,#start_key_sequence do
    next_key, rest_of_sequence = utils.splitFirstKey(full_key_sequence)
    next_key_in_start = utils.splitFirstKey(start_key_sequence)
    if next_key_in_start ~= next_key then
      return nil
    end
  end

  return rest_of_sequence
end

function entryToString(entry)
  if utils.isFolder(entry) then
    return entry[1]
  end
  return entry
end

function mergeEntries(t1, t2)
  if not t2 then
    return t1
  end
  for key_seq,entry in pairs(t2) do
    if t1[key_seq] then
      log.warn("Found key clash for sequence " .. key_seq .. " : " .. entryToString(t1[key_seq]) .. " and " .. entryToString(entry))
    end
    t1[key_seq] = entry
  end
end

function mergeFutureEntriesWithFolder(possible_future_entries, key_sequence, folder_key_sequence, folder)
  local folder_table = folder[2]
  if folder_key_sequence == key_sequence then
    mergeEntries(possible_future_entries, folder_table)
    return
  end

  local first_key, rest_of_sequence = utils.splitFirstKey(key_sequence)
  if folder_key_sequence == first_key then
    local future_entries_from_folder = getPossibleFutureEntriesForKeySequence(rest_of_sequence, folder_table)
    mergeEntries(possible_future_entries, future_entries_from_folder)
    return
  end
end

function getPossibleFutureEntriesForKeySequence(key_sequence, entries)
  if not entries then return nil end
  if not key_sequence then return nil end

  if key_sequence == "" then return entries end

  local entry = entries[key_sequence]
  if entry and not utils.isFolder(entry) then
    if utils.checkIfActionIsRegisterAction(entry) then
      return {"(register)"}
    end
    return nil
  end

  local possible_future_entries = {}

  for entry_key_sequence,entry in pairs(entries) do
    if utils.isFolder(entry) then
      mergeFutureEntriesWithFolder(possible_future_entries, key_sequence, entry_key_sequence,  entry)
    end

    local rest_of_sequence = stripBegginingKeys(entry_key_sequence, key_sequence)
    if rest_of_sequence then
      possible_future_entries[rest_of_sequence] = entry
    end
  end

  if next(possible_future_entries) == nil then
    return nil
  end

  return possible_future_entries
end

function getFutureEntriesOnActionSequence(key_sequence, sequence, entries)
  if #sequence == 0 then return nil end

  local current_entry_type = sequence[1]

  if regex_match_entry_types[current_entry_type] then
    if key_sequence == "" then
      return {"(" .. current_entry_type .. ")"}
    end
    local match, rest_of_sequence = utils.splitFirstMatch(key_sequence, match_regex)
    if match then
      table.remove(sequence, 1)
      return getFutureEntriesOnActionSequence(rest_of_sequence, sequence, entries)
    end
  end

  local entries_for_current_entry_type = entries[current_entry_type]
  if not entries_for_current_entry_type then return nil end
  if key_sequence == "" then return entries_for_current_entry_type end

  local completions = getPossibleFutureEntriesForKeySequence(key_sequence, entries_for_current_entry_type)
  if completions then
    return completions
  end

  local rest_of_sequence = key_sequence
  local sequence_to_try = ""
  while #rest_of_sequence ~= 0 do
    first_key, rest_of_sequence = utils.splitFirstKey(rest_of_sequence)
    sequence_to_try = sequence_to_try .. first_key
    local entry = utils.getEntryForKeySequence(sequence_to_try, entries_for_current_entry_type)

    if entry then
      table.remove(sequence, 1)
      return getFutureEntriesOnActionSequence(rest_of_sequence, sequence, entries)
    end
  end

  return nil
end

function getPossibleFutureEntries(state)
  local sequences = sequences.getPossibleSequences(state['context'], state['mode'])
  if not sequences then return nil end
  local entries = definitions.getPossibleEntries(state['context'])
  if not entries then return nil end

  local future_entries = {}
  local future_entry_exists = false
  for _, sequence in pairs(sequences) do
    local future_entries_on_sequence = getFutureEntriesOnActionSequence(state['key_sequence'], sequence, entries)
    if future_entries_on_sequence then
      future_entry_exists = true
      for key, entry in pairs(future_entries_on_sequence) do
        future_entries[key] = entry
      end
    end
  end

  if future_entry_exists then
    return future_entries
  end

  return nil
end

return getPossibleFutureEntries
