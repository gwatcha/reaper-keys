local project_io = {}

local serpent = require('serpent')

function project_io.write(ext, key, lua_table)
  local current_project, _ = reaper.EnumProjects(-1, "")
  local lua_table_string = serpent.block(lua_table, { comment = false })
  reaper.SetProjExtState(current_project, ext, key, lua_table_string)
end

function project_io.read(ext, key)
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
  reaper.DeleteExtState(ext, key, false)
end

return project_io
