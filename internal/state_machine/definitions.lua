local definitions = {}

local info = debug.getinfo(1,'S');
local root_path = info.source:match[[.*reaper.keys/]]:sub(2)
local definitions_dir = root_path .. "definitions/"

local table_io = require("utils.table_io")
local log = require("utils.log")
local str = require("string")

function read(definition_table_name)
  local ok, definitions = table_io.read(definitions_dir .. definition_table_name)
  if not ok then
    log.fatal("Couldn't read '" .. definition_table_name .. "': " .. definitions)
  end

  return definitions
end

function write(name, definition_table)
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

function findCommandInTable(command_sequence, definitions_table)
  local command_sequence_value = definitions_table[command_sequence]
  if command_sequence_value and not isFolder(command_sequence_value) then
    return command_sequence_value
  end

  local first_key, rest_of_command_sequence = stripFirstKey(command_sequence)
  local folder = definitions_table[first_key]
  if rest_of_command_sequence and folder and isFolder(folder) then
    local folder_table = folder[2]
    return findCommandInTable(rest_of_command_sequence,  folder_table)
  end

  return nil
end

function definitions.findCommand(command_sequence, definition_table_names, command_types)
  local definition_tables = {}
  for index, table_name in ipairs(definition_table_names) do
    definition_tables[index] = read(table_name)
  end

  log.info("finding sequence .." .. command_sequence)

  for _, definition_table in ipairs(definition_tables) do
    for _, command_type in ipairs(command_types) do
      local command = findCommandInTable(command_sequence, definition_table[command_type])
      if command then
        return command
      end
    end
  end
end

return definitions
