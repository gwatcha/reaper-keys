local definitions = {}

local info = debug.getinfo(1,'S');
local root_path = info.source:match[[.*reaper.keys/]]:sub(2)
local definitions_dir = root_path .. "internal/definitions/data/"

local table_io = require("utils.table_io")
local log = require("utils.log")
local str = require("string")
local ser = require("serpent")

function definitions.read(table_name)
  local ok, definitions = table_io.read(definitions_dir .. table_name)
  if not ok then
    log.fatal("Couldn't read '" .. table_name .. "', got: " .. definitions)
  end

  return definitions
end

function definitions.readMultiple(table_names)
  local tables = {}
  for index, table_name in ipairs(table_names) do
    tables[index] = definitions.read(table_name)
  end
  return tables
end

function definitions.write(name, definition_table)
  table_io.write(definitions_dir .. file, definition_table)
end

function isFolder(key_sequence_value)
  if key_sequence_value[1] and type(key_sequence_value[1]) == "string" then
    if key_sequence_value[2] and type(key_sequence_value[2]) == "table" then
      return true
    end
  end

  return false
end

function stripFirstKey(key_sequence)
  local first_char = str.sub(key_sequence, 1, 1)
  local first_key = first_char
  if first_char == "<" then
    local control_key = str.match(key_sequence, '(<%a*>)')
    if control_key then
      first_key = control_key
    end
  end

  local rest_of_sequence = str.sub(key_sequence, str.len(first_key) + 1)
  return first_key, rest_of_sequence
end

function definitions.findCommand(command_sequence, definitions_table_section)
  local command_sequence_value = definitions_table_section[command_sequence]
  if command_sequence_value and not isFolder(command_sequence_value) then
    return command_sequence_value
  end

  local first_key, rest_of_command_sequence = stripFirstKey(command_sequence)
  local folder = definitions_table_section[first_key]
  if rest_of_command_sequence and folder and isFolder(folder) then
    local folder_table = folder[2]
    return definitions.findCommand(rest_of_command_sequence,  folder_table)
  end

  return nil
end

function definitions.getCompletions(command_sequence, definitions_table_section)
  local command_sequence_value = definitions_table_section[command_sequence]
  if command_sequence_value and isFolder(command_sequence_value) then
      local folder_table = command_sequence_value[2]
      return folder_table
  end

  local sequence_completions = {}
  local found_sequence_completion = false
  for full_command_sequence, full_command_sequence_value in pairs(definitions_table_section) do
    rest_of_sequence, match = string.gsub(full_command_sequence, "^" .. command_sequence, "")
    if match == 1 then
      sequence_completions[rest_of_sequence] = full_command_sequence_value
      found_sequence_completion = true
    end
  end
  if found_sequence_completion then
    return sequence_completions
  end

  local first_key, rest_of_command_sequence = stripFirstKey(command_sequence)
  local folder = definitions_table_section[first_key]
  if rest_of_command_sequence and folder and isFolder(folder) then
    local folder_table = folder[2]
    return definitions.getCompletions(rest_of_command_sequence, folder_table)
  end

  return nil
end

return definitions
