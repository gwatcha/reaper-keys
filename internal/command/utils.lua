local str = require('string')
local log = require('utils.log')
local ser = require('serpent')

local utils = {}

function utils.checkIfActionHasOptionSet(action_name, parameter_name)
  if utils.isFolder(action_name) then
    return false
  end

  local action = getAction(action_name)
  if action and type(action) == 'table' and action[parameter_name] then
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
  local match = str.match(key_sequence, match_regex)
  if match then
    local rest_of_sequence = str.sub(key_sequence, str.len(match) + 1)
    return match, rest_of_sequence
  end

  return nil, key_sequence
end

function utils.splitKeysIntoTable(key_sequence)
  -- lua unfortunately has no '|' (or) operator in regex, so I make multiple and iterate
  local key_capture_regex = {'(<[^<>]+>)', '(<[^<>]+[<>]>)', '.'}

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

function table.shallow_copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

function utils.getActionValue(action_key, action_type)
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
