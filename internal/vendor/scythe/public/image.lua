--- @module Image

local Buffer = require("public.buffer")
local File = require("public.file")
local Table = require("public.table")
local T = Table.T

local validExtensions = {
  png = true,
  jpg = true,
}

local Image = {}

local loadedImages = T{}

--- Attempts to load the specified image, reusing previously-loaded images.
-- @param path string The path to an image
-- @return number|boolean A buffer number, or `false` if it couldn't load the image.
Image.load = function(path)
  if loadedImages[path] then return loadedImages[path] end

  local buffer = Buffer.get()
  local ret = gfx.loadimg(buffer, path)

  if ret > -1 then
    loadedImages[path] = buffer
    return buffer
  else
    error("Couldn't load image: " .. path)
    Buffer.release(buffer)
  end

  return false
end


--- Unloads an image, clearing and releasing its buffer
-- @param path string The path that was used to load the image
Image.unload = function(path)
  local buffer = loadedImages[path]
  if buffer then
    Buffer.release(buffer)
    gfx.setimgdim(buffer, -1, -1)
    loadedImages[path] = nil
  end

end

--- Checks if an image file can be loaded by Reaper
-- @param path string The path to an image
-- @return boolean
Image.hasValidImageExtension = function(path)
  local ext = path:match("%.(.-)$")
  return validExtensions[ext]
end

--- Loads all of the valid images in a folder
-- @param path string The path to a set of images
-- @return hash An object of the form `{ path = path, images = {["/path/image.png"] = 4} }`
Image.loadFolder = function(path)
  local folderTable = {path = path, images = T{}}

  for _, file in File.files(path) do
    if Image.hasValidImageExtension(file) then
      local buffer = Image.load(path.."/"..file)
      if buffer then
        folderTable.images[file] = buffer
      end
    end
  end

  return folderTable
end

--- Unloads all of the images in a given folder
-- @param folderTable hash An object of the form `{ path = path, images = {["/path/image.png"] = 4} }`,
-- as returned by `Image.loadFolder`.
Image.unloadFolder = function(folderTable)
  for k in pairs(folderTable.images) do
    Image.unload(folderTable.path.."/"..k)
  end
end

--- Attemps to find the path associated with a given buffer
-- @param buffer number A graphics buffer
-- @return string|boolean Returns the image path if found, otherwise returns `nil`.
Image.getPathFromBuffer = function(buffer)
  local path = loadedImages:find(function(v, k) return (v == buffer) and k end)
  if not path then error("Graphics buffer " .. buffer .. " has not been used by an image file.") end

  return path
end


return Image
