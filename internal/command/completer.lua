local sequences = require("command.sequences")
local utils = require("command.utils")
local definitions = require("utils.definitions")
local regex_match_entry_types = require("command.constants").regex_match_entry_types

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

function getPossibleFutureEntriesForKeySequence(key_sequence, entries)
  if not entries then return nil end
  if key_sequence == "" then return entries end

  local entry = entries[key_sequence]
  if entry and not utils.isFolder(entry) then return nil end

  local possible_future_entries = {}
  if entry and utils.isFolder(entry) then
    local folder_table = entry[2]
    possible_future_entries = folder_table
  end

  local found_possible_future_entry = false
  for full_key_sequence, entry_value in pairs(entries) do
    rest_of_sequence = stripBegginingKeys(full_key_sequence, key_sequence)
    if rest_of_sequence and not utils.isFolder(entry_value) then
      possible_future_entries[rest_of_sequence] = entry_value
      found_possible_future_entry = true
    end
  end
  if found_possible_future_entry then
    return possible_future_entries
  end

  local first_key, rest_of_key_sequence = utils.splitFirstKey(key_sequence)
  local possible_folder = entries[first_key]
  if rest_of_key_sequence and utils.isFolder(possible_folder) then
    local folder = possible_folder
    local folder_table = folder[2]
    return getPossibleFutureEntriesForKeySequence(rest_of_key_sequence, folder_table)
  end

  return nil
end

-- i am not proud of how complicated this is
function getFutureEntriesOnSequence(key_sequence, action_sequence, entries)
  if #action_sequence == 0 then return nil end

  local current_entry_type = action_sequence[1]

  if regex_match_entry_types[current_entry_type] then
    if key_sequence == "" then
      return {"(" .. current_entry_type .. ")"}
    end

    local match_regex = regex_match_entry_types[current_entry_type]
    local match, rest_of_sequence = utils.splitFirstMatch(key_sequence, match_regex)
    if match then
      table.remove(action_sequence, 1)
      return getFutureEntriesOnSequence(rest_of_sequence, action_sequence, entries)
    end
    return nil
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
      table.remove(action_sequence, 1)
      return getFutureEntriesOnSequence(rest_of_sequence, action_sequence, entries)
    end
  end

  return nil
end

function getPossibleFutureEntries(state)
  local action_sequences = sequences.getPossibleActionSequences(state['context'], state['mode'])
  if not action_sequences then return nil end
  local entries = definitions.getPossibleEntries(state['context'])
  if not entries then return nil end

  local future_entries = {}
  local future_entry_exists = false
  for _, action_sequence in pairs(action_sequences) do
    local future_entries_on_sequence = getFutureEntriesOnSequence(state['key_sequence'], action_sequence, entries)
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
