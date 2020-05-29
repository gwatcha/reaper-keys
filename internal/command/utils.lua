local str = require('string')
local log = require('utils.log')
local ser = require('serpent')
local command_constants = require('command.constants')
local regex_match_entry_types = command_constants.regex_match_entry_types
local regex_match_values = command_constants.regex_match_values

local utils = {}

function utils.checkIfActionIsRegisterOptional(action_name)
  local action = getAction(action_name)
  if action and type(action) == 'table' and action['registerOptional'] then
    return true
  end
  return false
end

function utils.checkIfActionIsRegisterAction(action_name)
  local action = getAction(action_name)
  if action and type(action) == 'table' and action['registerAction'] then
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

function utils.getActionTypeIndex(command, action_type)
  for i,current_action_type in pairs(command.sequence) do
    if current_action_type == action_type then
      return i
    end
  end
  return nil
end

function utils.getEntry(key_sequence, entries)
  if entries[key_sequence] then
    return entries[key_sequence]
  end
  for k, sub_command_name in pairs(entries) do
    if actions[sub_command_name]['format'] then
      local match = str.match(key_sequence, k)
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
  -- FIXME why is match_regex parameter nil when i can print it? this is
  -- hardcoded for now so i don't lose my sanity
  match_regex = '[1-9][0-9]*'
  local match = str.match(key_sequence, match_regex)
  if match then
    local rest_of_sequence = str.sub(key_sequence, str.len(match) + 1)
    return match, rest_of_sequence
  end

  return nil, key_sequence
end

function utils.splitFirstKey(key_sequence)
  local first_char = str.sub(key_sequence, 1, 1)
  local first_key = first_char
  if first_char == '<' then
    local control_key_regex = '(<[^(><)]*>)'
    local control_key = str.match(key_sequence, control_key_regex)
    local second_char = str.sub(key_sequence, 2, 2)
    if control_key and second_char ~= '<'then
      first_key = control_key
    end
  end

  local rest_of_sequence = str.sub(key_sequence, str.len(first_key) + 1)
  return first_key, rest_of_sequence
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

function table.shallow_copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

function utils.getActionValue(action_key, action_type)
  if regex_match_entry_types[action_type] then
    local matched = action_key
    return regex_match_values[action_type](matched)
  end

  if type(action_key) ~= 'table' then
    action_key = {action_key}
  end

  local action_name = action_key[1]
  local action = getAction(action_name)
  if not action then
    log.error("Could not find action for " .. action_name)
    return nil
  end

  local action_value = table.shallow_copy(action_key)
  if type(action) == 'table' then
    for k,v in pairs(action) do action_value[k] = v end
  else
    action_value[1] = action
  end

  return action_value
end

function utils.getActionValues(command)
  local action_values = {}
  for i,action_type in pairs(command.sequence) do
      local action_value = utils.getActionValue(command.action_keys[i], action_type)
      if not action_value then
        return nil
      end
      table.insert(action_values, action_value)
    end
  return action_values
end

return utils
