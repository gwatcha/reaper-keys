local project_io = {}

local serpent = require('serpent')

function project_io.overwrite(ext, key, lua_table)
  local current_project, _ = reaper.EnumProjects(-1, "")
  local lua_table_string = serpent.block(lua_table, { comment = false })
  reaper.SetProjExtState(current_project, ext, key, lua_table_string)
end

function project_io.getAll(ext)
  local keys = {}
  local max_keys = 5000
  local exists = false
  for i=0,max_keys do
    ok, key, val = reaper.EnumProjExtState(0, ext, i)
    if not ok then
      break
    end

    ok, lua_table = serpent.load(val)
    if not ok then
      return false, keys
    end

    keys[key] = lua_table
    exists = true
  end

  return exists, keys
end

function project_io.get(ext, key)
  local current_project, _ = reaper.EnumProjects(-1, "")
  exists, value = reaper.GetProjExtState(project, ext, key)
  if exists then
    ok, lua_table = serpent.load(value)
    if not ok then
      return false, lua_table
    end

    return ok, lua_table
  end

  return false, 'Does not exist'
end

function project_io.clear(ext, key)
  local current_project, _ = reaper.EnumProjects(-1, "")
  reaper.DeleteExtState(ext, key, true)
end

return project_io
