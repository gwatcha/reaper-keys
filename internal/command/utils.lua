local str = require("string")

local utils = {}

function utils.checkIfCommandsAreEqual(command1, command2)
  if #command1.sequence ~= #command2.sequence then return false end
  for i,action in pairs(command1.parts) do
    if action ~= command2.parts[i] then
      return false
    end
  end
  return true
end

function utils.getActionTypeValueInCommand(command, action_type)
  for i,current_action_type in pairs(command.sequence) do
    if current_action_type == action_type then
      return command.parts[i]
    end
  end
  return nil
end

function utils.makeCommandDescription(command)
  local desc = ""
  for _, command_part  in pairs(command.parts) do
    desc = desc .. command_part .. " "
  end
  return desc
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

function utils.splitFirstMatch(key_sequence, regex)
  local match = str.match(key_sequence, "^" .. regex)
  if match then
    local rest_of_sequence = str.sub(key_sequence, str.len(match) + 1)
    return match, rest_of_sequence
  end

  return nil, key_sequence
end

function utils.splitFirstKey(key_sequence)
  local first_char = str.sub(key_sequence, 1, 1)
  local first_key = first_char
  if first_char == "<" then
    local control_key_regex = '(<[^(><)]*>)'
    local control_key = str.match(key_sequence, control_key_regex)
    if control_key then
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

function utils.qualifiesAsRepeatableCommand(command)
  for _,action_type in ipairs(command.sequence) do
    if action_type:find('command') then
      return true
    end
  end

  return false
end

return utils
