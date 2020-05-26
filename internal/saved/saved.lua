local info = debug.getinfo(1,'S');

local internal_root_path = info.source:match(".*reaper.keys[^\\/]*[\\/]internal[\\/]"):sub(2)

local saved_data_dir = ""
local windows_files = internal_root_path:match("\\$")
if windows_files then
  saved_data_dir = internal_root_path .. "\\saved\\data\\"
else
  saved_data_dir = internal_root_path .. "/saved/data/"
end

local table_io = require('utils.table_io')
local log = require('utils.log')

local saved = {
  macros = {}
}

function readSavedData(name)
  local ok, data = table_io.read(saved_data_dir .. name)
  if not ok then
    log.warn("Could not read data from file, it may have become corrupted.")
    return {}
  end
  return data
end

function writeSavedData(name, data)
  table_io.write(saved_data_dir .. name, data)
end

function saved.macros.append(register, command)
  local macros = readSavedData('macros')
  if macros[register] then
    table.insert(macros[register], command)
  else
    macros[register] = {command}
  end

  writeSavedData('macros', macros)
end

function saved.macros.clear(register)
  local macros_table = readSavedData('macros')
  macros_table[register] = nil
  writeSavedData('macros', macros_table)
end

function saved.macros.get(register)
  local macros = readSavedData('macros')
  return macros[register]
end

return saved
