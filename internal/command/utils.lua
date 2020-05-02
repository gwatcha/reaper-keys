local log = require("utils.log")
local str = require("string")
local ser = require("serpent")

local utils = {}

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

function utils.printEntries(entries)
  local max_seq_length = 1
  for key_seq,_ in pairs(entries) do
    if type(key_seq) == 'string' and #key_seq > max_seq_length then
      max_seq_length = #key_seq
    end
  end

  local collapsed_entries = {}
  local entries_string = ""
  for key_seq, value in pairs(entries) do
    local pretty_key_seq = key_seq
    if str.sub(key_seq, 1, 1) == "<" and str.sub(key_seq, #key_seq, #key_seq) == ">" then
      pretty_key_seq = str.sub(key_seq, 2, #key_seq - 1)
    end

    local entry_string = "  "
    if key_seq == 'number' then
      entry_string = entry_string .. value
    else
      entry_string = entry_string .. "'" .. pretty_key_seq .. "'" .. " -> "
      if utils.isFolder(value) then
        local folder_name = value[1]
        entry_string = entry_string .. folder_name
      else
        entry_string = entry_string .. value
      end
    end

    entry_string = str.format("%" .. max_seq_length + 2 .. "s -> %s", pretty_key_seq, value)

    entries_string = entries_string .. "\n" .. entry_string
  end

  return entries_string
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

return utils
