local string_util = require('string')
local log = require 'log'
local ser = require('serpent')

local utils = {}

function utils.stripBegginingKeys(full_key_sequence, start_key_sequence)
  if #start_key_sequence >= #full_key_sequence then
    return nil
  end

  if #start_key_sequence == 0 then
    return full_key_sequence
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

function noNextTableEntry(t1)
  if next(t1) == nil then
    return true
  end
  return false
end

function utils.filterEntries(options, entries)
  local filtered_entries = {}
  for key_seq,entry_val in pairs(entries) do
    if utils.isFolder(entry_val) then
      local folder = entry_val
      local folder_name = folder[1]
      local folder_table = folder[2]
      local filtered_entries_for_folder = utils.filterEntries(options, folder_table)
      if not noNextTableEntry(filtered_entries_for_folder) then
        filtered_entries[key_seq] = {folder_name, filtered_entries_for_folder}
      end
    else
      local action_name = entry_val
      if utils.checkIfActionHasOptionsSet(action_name, options) then
        filtered_entries[key_seq] = entry_val
      end
    end
  end

  return filtered_entries
end

function utils.checkIfActionHasOptionsSet(action_name, option_names)
  for _, option_name in ipairs(option_names) do
    if not utils.checkIfActionHasOptionSet(action_name, option_name) then
      return false
    end
  end
  return true
end

function utils.checkIfActionHasOptionSet(action_name, option_name)
  if utils.isFolder(action_name) then
    return false
  end

  local action = getAction(action_name)
  if action and type(action) == 'table' and action[option_name] then
    return true
  end
  return false
end

function utils.checkIfCommandsAreEqual(command1, command2)
  if ser.block(command1, {comment=false}) == ser.block(command2, {comment=false}) then
    return true
  end
  return false
end

function utils.getEntry(key_sequence, entries)
  if entries[key_sequence] then
    return entries[key_sequence]
  end
  for k, sub_command_name in pairs(entries) do
    if actions[sub_command_name]['format'] then
      local match = string_util.match(key_sequence, k)
      if match then
      end
    end
  end
end

function utils.isFolder(entry_value)
  if entry_value then
    if entry_value[1] and type(entry_value[1]) == "string" then
      if entry_value[2] and type(entry_value[2]) == "table" then
        return true
      end
    end
  end

  return false
end

function utils.splitFirstMatch(key_sequence, match_regex)
  local match = string_util.match(key_sequence, match_regex)
  if match then
    local rest_of_sequence = string_util.sub(key_sequence, string_util.len(match) + 1)
    return match, rest_of_sequence
  end

  return nil, key_sequence
end

function utils.splitKeysIntoTable(key_sequence)
  -- lua unfortunately has no '|' (or) operator in regex, so I make multiple and iterate
  local key_capture_regex = {'^(<[^<>]+>)', '^(<[^<>]+[<>]>)', '^.'}

  local keys = {}
  local i = 1
  while i <= #key_sequence do
    for _,capture_regex in ipairs(key_capture_regex) do
      local next_key = string.match(key_sequence, capture_regex, i)
      if next_key then
        table.insert(keys, next_key)
        i = i + #next_key
        break
      end
    end
  end

  return keys
end

function utils.splitFirstKey(key_sequence)
  local keys = utils.splitKeysIntoTable(key_sequence)
  return keys[1], table.concat(keys, "", 2)
end

function utils.splitLastKey(key_sequence)
  local keys = utils.splitKeysIntoTable(key_sequence)
  return table.concat(keys, "", 1, #keys - 1), keys[#keys]
end

function utils.getEntryForKeySequence(key_sequence, entries)
  local entry = entries[key_sequence]
  if entry and not utils.isFolder(entry) then
    return entry
  end
  local first_key, rest_of_key_sequence = utils.splitFirstKey(key_sequence)
  local possible_folder = entries[first_key]
  if rest_of_key_sequence and utils.isFolder(possible_folder) then
    local folder_table = possible_folder[2]
    return utils.getEntryForKeySequence(rest_of_key_sequence,  folder_table)
  end
  return nil
end

return utils
