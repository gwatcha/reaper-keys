local action_sequences = require('command.action_sequences')
local utils = require('command.utils')
local definitions = require('utils.definitions')
local log = require('utils.log')
local format = require('utils.format')

function entryToString(entry)
  if utils.isFolder(entry) then
    return entry[1]
  end
  return entry
end

function noNextTableEntry(t1)
  if next(t1) == nil then
    return true
  end
  return false
end

function mergeEntries(t1, t2)
  if not t2 then
    return t1
  end
  for key_seq,entry_val in pairs(t2) do
    if t1[key_seq] then
      log.warn("Found key clash for action_sequence " .. key_seq .. " : " .. entryToString(t1[key_seq]) .. " and " .. entryToString(entry_val))
    end
    t1[key_seq] = entry_val
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

  local possible_future_entries = {}

  local number_match, key_sequence_no_number = utils.splitFirstMatch(key_sequence, '[1-9][0-9]*')
  if number_match then
    local number_prefix_entries = utils.filterEntries({"prefixRepetitionCount"}, entries)
    local possible_future_entries_if_number_prefix = getPossibleFutureEntriesForKeySequence(key_sequence_no_number, number_prefix_entries)
    mergeEntries(possible_future_entries, possible_future_entries_if_number_prefix)
  end

  for entry_key_sequence,entry_val in pairs(entries) do
    local completion_sequence = utils.stripBegginingKeys(entry_key_sequence, key_sequence)
    if completion_sequence then
      possible_future_entries[completion_sequence] = entry_val
    end
    if utils.isFolder(entry_val) then
      local folder = entry_val
      mergeFutureEntriesWithFolder(possible_future_entries, key_sequence, entry_key_sequence, folder)
    else
      local action_name = entry_val
      if key_sequence == entry_key_sequence and utils.checkIfActionHasOptionSet(action_name, 'registerAction') then
        possible_future_entries["(key)"] = "(register)"
      end
    end
  end

  if next(possible_future_entries) == nil then
    return nil
  end

  return possible_future_entries
end

function getFutureEntriesOnActionSequence(key_sequence, action_sequence, entries)
  if #action_sequence == 0 then return nil end

  local current_action_type = action_sequence[1]

  local entries_for_current_action_type = entries[current_action_type]
  if not entries_for_current_action_type then return nil end
  if key_sequence == "" then return entries_for_current_action_type end

  local completions = getPossibleFutureEntriesForKeySequence(key_sequence, entries_for_current_action_type)
  if completions then
    return completions
  end

  local rest_of_sequence = key_sequence
  local key_sequence_to_try = ""
  while #rest_of_sequence ~= 0 do
    first_key, rest_of_sequence = utils.splitFirstKey(rest_of_sequence)
    key_sequence_to_try = key_sequence_to_try .. first_key
    local entry = utils.getEntryForKeySequence(key_sequence_to_try, entries_for_current_action_type)

    if entry then
      table.remove(action_sequence, 1)
      return getFutureEntriesOnActionSequence(rest_of_sequence, action_sequence, entries)
    end
  end

  return nil
end

function getPossibleFutureEntries(state)
  local action_sequences = action_sequences.getPossibleActionSequences(state['context'], state['mode'])
  if not action_sequences then return nil end
  local entries = definitions.getPossibleEntries(state['context'])
  if not entries then return nil end

  local future_entries = {}
  local future_entry_exists = false
  for _, action_sequence in pairs(action_sequences) do
    local future_entries_on_action_sequence = getFutureEntriesOnActionSequence(state['key_sequence'], action_sequence, entries)
    if future_entries_on_action_sequence then
      future_entry_exists = true
      for key, entry in pairs(future_entries_on_action_sequence) do
        if not future_entries[key] then
          future_entries[key] = entry
        end
      end
    end
  end

  if future_entry_exists then
    return future_entries
  end

  return nil
end

return getPossibleFutureEntries
