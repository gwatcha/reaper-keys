local args = {...}

-- If the library is inadvertently loaded from multiple files, just add any
-- additional options and skip everything else
if Scythe then
  if args and args[1] then
    for k, v in pairs(args) do
      if v then Scythe.args[k] = true end
    end
  end

  return
end

Scythe = {}
Scythe.args = args and args[1] or {}

Scythe.libPath = reaper.GetExtState("Scythe v3", "libPath")
if not Scythe.libPath or Scythe.libPath == "" then
    reaper.MB("Couldn't find the Scythe library. Please run 'Set Scythe library path' in your Action List.", "Whoops!", 0) -- luacheck: ignore 631
    return
end

Scythe.libRoot = Scythe.libPath:match("(.*[/\\])".."[^/\\]+[/\\]")

local function addPaths()
  local paths = {
    Scythe.libPath:match("(.*[/\\])")
  }

  if Scythe.args.dev then
    paths[#paths + 1] = Scythe.libRoot .. "development/"
    paths[#paths + 1] = Scythe.libRoot .. "deployment/"
  end

  for i, path in pairs(paths) do
    paths[i] = ";" .. path .. "?.lua"
  end

  package.path = package.path .. table.concat(paths, "")
end
addPaths()

require("public.string")
local Message = require("public.message")
Msg = Msg or Message.Msg
qMsg = qMsg or Message.queueMsg
printQMsg = printQMsg or Message.printQueue

if not os then Scythe.scriptRestricted = true end

local Error = require("public.error")
Scythe.wrapErrors = function(fn) xpcall(fn, Error.handleError) end

local context
Scythe.getContext = function()
  if context then return context end

  local c = ({reaper.get_action_context()})

  local contextTable = {
    isNewValue = c[1],
    filename = c[2],
    sectionId = c[3],
    commandId = c[4],
    midiMode = c[5],
    midiResolution = c[6],
    midiValue = c[7]
  }

  contextTable.scriptPath, contextTable.scriptName = c[2]:match("(.-)([^/\\]+).lua$")
  context = contextTable

  return context
end

Scythe.version = (function()

  local file = Scythe.libPath .. "/scythe.lua"
  if not reaper.ReaPack_GetOwner then
    return "(" .. "ReaPack not found" .. ")"
  else
    local package, err = reaper.ReaPack_GetOwner(file)
    if not package or package == "" then
      return err == "the file is not owned by any package entry"
        and "v3.x"
        or "(" .. tostring(err) .. ")"
    else
      -- ret, repo, cat, pkg, desc, type, ver, author, pinned, fileCount = reaper.ReaPack_GetEntryInfo(package)
      local ret, _, _, _, _, _, ver, _, _, _ =
        reaper.ReaPack_GetEntryInfo(package)

      return ret and ("v" .. tostring(ver)) or "(version error)"
    end
  end

end)()

Scythe.hasSWS = reaper.APIExists("CF_GetClipboardBig")
