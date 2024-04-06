--- @module Buffer
-- Manages the graphics buffers available to a script

local Table = require("public.table")
local T = Table.T

local Buffer = {}

-- Any assigned buffers will be marked as N = true here
local assignedBuffers = {}

-- When deleting elements, their buffer numbers
-- will be added here for easy access.
local releasedBuffers = T{}

--- Assigns a given number of buffer numbers; these numbers will not be assigned
-- again until they are explicitly released.
-- @option num number Defaults to 1
-- @return number|table   Returns a buffer number if only one is requested, or a
-- table of buffers otherwise
Buffer.get = function (num)
  local ret = {}

  for i = 1, (num or 1) do

    if #releasedBuffers > 0 then

      ret[i] = releasedBuffers:remove()

    else
      for j = 1, 1023 do

        if not assignedBuffers[j] then
          ret[i] = j

          assignedBuffers[j] = true
          goto skip
        end

      end

      error("Unable to find an unused graphics buffer")

      ::skip::
    end

  end

  return (#ret == 1) and ret[1] or ret

end

--- Releases one or more buffer numbers, allowing them to be reassigned. Elements
-- using buffers should make sure to release them when being deleted.
-- @param num number|table A buffer number, or a table of buffer numbers
Buffer.release = function (num)

  if type(num) == "number" then
    releasedBuffers:insert(num)
  else
    for _, v in pairs(num) do
      releasedBuffers:insert(v)
    end
  end

end

return Buffer
