local sequences = require("command.sequences")
local utils = require("command.utils")
local definitions = require("utils.definitions")
local log = require("utils.log")
local regex_match_entry_types = require("command.constants").regex_match_entry_types

local str = require("string")
local ser = require("serpent")

function getPossibleFutureEntriesForKeySequence(key_sequence, entries)
  if not entries then return nil end
  if key_sequence == "" then return entries end

  local entry = entries[key_sequence]
  if entry and utils.isFolder(entry) then
      local folder_table = entry[2]
      return folder_table
  end

  if entry then return nil end

  local possible_future_entries = {}

  local found_possible_future_entry = false
  for full_key_sequence, entry_value in pairs(entries) do
    rest_of_sequence, full_seq_starts_with_key_seq = string.gsub(full_key_sequence, "^" .. key_sequence, "")
    if full_seq_starts_with_key_seq == 1 then
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

function getFutureEntriesOnSequence(key_sequence, action_sequence, entries)
  if #action_sequence == 0 then return nil end

  local current_entry_type = action_sequence[1]

  if regex_match_entry_types[current_entry_type] then
    if key_sequence == "" then return {"(" .. current_entry_type .. ")"} end

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
  while #rest_of_sequence ~= 0 do
    first_key, rest_of_sequence = utils.splitFirstKey(rest_of_sequence)
    local entry = utils.getEntryForKeySequence(first_key, entries_for_current_entry_type)
    if entry then
      table.remove(action_sequence, 1)
      return getFutureEntriesOnSequence(rest_of_sequence, action_sequence, entries)
    end
  end

  return nil
end

function getPossibleFutureEntries(state, key_sequence)
  local action_sequences = sequences.getPossibleActionSequences(state['context'], state['mode'])
  if not action_sequences then return nil end
  local entries = definitions.getPossibleEntries(state['context'])
  if not entries then return nil end

  local future_entries = {}
  local future_entry_exists = false
  for _, action_sequence in pairs(action_sequences) do
    local future_entries_on_sequence = getFutureEntriesOnSequence(key_sequence, action_sequence, entries)
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
