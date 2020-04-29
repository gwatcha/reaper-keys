local info = debug.getinfo(1,'S');
local root_path = info.source:match[[.*reaper.keys/]]:sub(2)
local definitions_dir = root_path .. "internal/definitions/data/"

local table_io = require("utils.table_io")
local log = require("utils.log")
local str = require("string")
local ser = require("serpent")

local definitions = {}

function definitions.read(table_name)
  local ok, definitions = table_io.read(definitions_dir .. table_name)
  if not ok then
    log.fatal("Couldn't read '" .. table_name .. "', got: " .. definitions)
  end

  return definitions
end

function definitions.write(name, definition_table)
  table_io.write(definitions_dir .. file, definition_table)
end

return definitions
