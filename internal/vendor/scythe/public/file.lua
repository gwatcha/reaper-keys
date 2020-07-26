--- @module File

local T = require("public.table").T
local File = {}

--- An iterator that loops over the files in a specified path.
-- @param path string A folder
-- @return iterator
File.files = function(path, idx)
  if not path then return end
  if not idx then return File.files, path, -1 end

  idx = idx + 1
  local file = reaper.EnumerateFiles(path, idx)

  if file then return idx, file end
end

--- An iterator that loops over the folders in a specified path.
-- @param path string A folder
-- @return iterator
File.folders = function(path, idx)
  if not path then return end
  if not idx then return File.folders, path, -1 end

  idx = idx + 1
  local folder = reaper.EnumerateSubdirectories(path, idx)

  if folder then return idx, folder end
end

--- Collects the files in a specified path, with optional filtering.
-- @param path string A folder
-- @option filter function Used to filter the included files. If `filter(file)`
-- is falsy, a file will not be included.
-- @return array Files, of the form `{ name = "file.name", path = "fullpath/file.name" }`
File.getFiles = function(path, filter)
  local addSeparator = path:match("[\\/]$") and "" or "/"
  local files = T{}

  for _, file in File.files(path) do
    if not filter or filter(file) then
      files[#files+1] = { name = file, path = path..addSeparator..file }
    end
  end

  return files
end

--- Collects the folders in a specified path, with optional filtering.
-- @param path string A folder
-- @option filter function Used to filter the included folder. If `filter(fullpath)`
-- is falsy, a folder will not be included.
-- @return array Folders, of the form `{ name = "folder", path = "fullpath/folder" }`
File.getFolders = function(path, filter)
  local addSeparator = path:match("[\\/]$") and "" or "/"
  local folders = T{}

  for _, folder in File.folders(path) do
    if not filter or filter(folder) then
      folders[#folders+1] = { name = folder, path = path..addSeparator..folder }
    end
  end

  return folders
end

--- Collects all of the files in a specified path, recursing through any subfolders,
-- with optional filtering.
-- @param path string A folder
-- @option filter function Used to filter the included files. If `filter(name, fullpath)`
-- is falsy, a file will not be included. When subfolders are present, they will
-- be skipped if `filter(name, fullpath, isFolder = true)` is falsy.
-- @return array Files, of the form `{ name = "file.name", path = "fullpath/file.name" }`
File.getFilesRecursive = function(path, filter, acc)
  if not acc then acc = T{} end

  local addSeparator = path:match("[\\/]$") and "" or "/"

  for _, file in File.files(path) do
    if not filter or filter(file, path) then
      acc[#acc+1] = { name = file, path = path..addSeparator..file }
    end
  end

  for _, folder in File.folders(path) do
    if not filter or filter(folder, path, true) then
      File.getFilesRecursive(path..addSeparator..folder, filter, acc)
    end
  end

  return acc
end

-- TODO: Tests
--- Checks if a given path exists, creating any missing folders if necessary
-- @param path string A folder path
-- @return boolean Returns `true` if successful, otherwise `nil`
File.ensurePathExists = function(path)
  local sanitized = path:match("(.+)[\\/]?$")

  if reaper.file_exists(sanitized) then return true end
  if reaper.RecursiveCreateDirectory(sanitized, 0) then return true end
end

return File
