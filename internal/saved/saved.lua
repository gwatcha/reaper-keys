local table_io = require('utils.table_io')
local log = require('utils.log')

local info = debug.getinfo(1,'S');
local internal_root_path = info.source:match(".*reaper.keys[^\\/]*[\\/]internal[\\/]"):sub(2)

local saved_data_dir = ""
local windows_files = internal_root_path:match("\\$")
if windows_files then
  saved_data_dir = internal_root_path .. "\\saved\\data\\"
else
  saved_data_dir = internal_root_path .. "/saved/data/"
end

local saved = {}


function saved.getAll(name)
  local ok, data = table_io.read(saved_data_dir .. name)
  if not ok then
    log.error("Could not read saved data '" .. name .. "' from file, it may have become corrupted.")
    return {}
  end
  return data
end

function saved.get(name, register)
  local data = saved.getAll(name)
  return data[register]
end
function saved.overwriteAll(name, data)
  table_io.write(saved_data_dir .. name, data)
end

function saved.overwrite(name, register, new_data)
  local all_data = saved.getAll(name)
  all_data[register] = {new_data}
  saved.overwriteAll(name, all_data)
end

function saved.append(name, register, new_data)
  local all_data = saved.getAll(name)
  if all_data[register] then
    table.insert(all_data[register], new_data)
  else
    all_data[register] = {new_data}
  end

  saved.overwriteAll(name, all_data)
end

function saved.clear(name, register)
  local all_data = saved.getAll(name)
  all_data[register] = nil
  saved.overwriteAll(name, all_data)
end

return saved
