local def = require("definitions")
local log = require("utils.log")
local str = require("string")
local ser = require("serpent")

local utils = {}

function utils.checkIfCommandFollowsSequence(command, entry_type_sequence)
  local i = 1
  local length = 0
  for entry_type, _ in pairs(command) do
    length = length + 1
    if entry_type ~= entry_type_sequence[i] then
      return false
    end
    i = i + 1
  end

  if length ~= #entry_type_sequence then
    return false
  end

  return true
end


function utils.isFolder(entry)
  if entry then
    if entry[1] and type(entry[1]) == "string" then
      if entry[2] and type(entry[2]) == "table" then
        return true
      end
    end
  end

  return false
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
function utils.splitFirstMatch(key_sequence, regex)
  local match = str.match(key_sequence, "^" .. regex)
  if match then
    local rest_of_sequence = str.sub(key_sequence, str.len(match) + 1)
    return match, rest_of_sequence
  end

  return nil, key_sequence
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
