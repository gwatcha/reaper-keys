--- @module Layer
-- A container that manages GUI elements
-- @param name string
-- @option z number The layer's front-to-back position. Lower values are "closer"
-- to the screen, higher values are farther away. Defaults to 1, which is also
-- the lowest accepted value.
local Table = require("public.table")
local T = Table.T
local Buffer = require("public.buffer")

local Layer = T{}
Layer.__index = Layer
Layer.__noRecursion = true

function Layer:new(props)
  local layer = Table.deepCopy(props or {})

  if not layer.z then layer.z = 1 end

  layer.elementCount = 0
  layer.elements = T{}

  layer.hidden = false
  layer.frozen = false

  layer.needsRedraw = false

  return setmetatable(layer, self)
end

--- Hides the layer from view, pausing any updates and preventing any user
-- interaction.
function Layer:hide()
  self.hidden = true
  self.needsRedraw = true
end

--- Shows a hidden layer, resuming updates and allowing user interaction.
function Layer:show()
  self.hidden = false
  self.needsRedraw = true
end

--- Adds one or more elements to the layer. Elements will be removed from any
-- previous layers, and initialized if the layer is attached to an open window.
-- @param ... elements One or more elements
function Layer:addElements(...)
  for _, elm in pairs({...}) do
    if elm.layer then elm.layer:removeElements(elm) end

    self.elements[elm.name] = elm
    elm.layer = self
    self.elementCount = self.elementCount + 1

    if self.window and self.window.isOpen then elm:init() end
  end

  self.needsRedraw = true
  return self
end

--- Removes one or more elements from the layer.
function Layer:removeElements(...)
  for _, elm in pairs({...}) do
    self.elements[elm.name] = nil
    elm.layer = nil
    self.elementCount = self.elementCount - 1
  end

  self.needsRedraw = true
  return self
end


function Layer:init()
  self.buffer = Buffer.get()

  for _, elm in pairs(self.elements) do
    elm:init()
  end
end

--- Deletes the layer. Any attached elements will be removed and returned.
-- @return hash Any elements that were attached to the layer.
function Layer:delete()
  local elements = ({table.unpack(self.elements)})

  self:removeElements(table.unpack(self.elements))
  Buffer.release(self.buffer)
  self.window.needsRedraw = true

  return elements
end


function Layer:update(state, last)
  if self.elementCount > 0 and not (self.hidden or self.frozen) then
    for _, elm in pairs(self.elements) do
      elm:update(state, last)
    end
  end
end

function Layer:redraw()

  -- Set this before we redraw, so that elms can call a subsequent redraw
  -- from their own :draw method. e.g. Labels fading out
  self.needsRedraw = false

  gfx.setimgdim(self.buffer, -1, -1)
  gfx.setimgdim(self.buffer, self.window.currentW, self.window.currentH)

  gfx.dest = self.buffer

  for _, elm in pairs(self.elements) do
    -- Reset these just in case an element or some user code forgot to,
    -- otherwise we get things like the whole buffer being blitted with a=0.2
    gfx.mode = 0
    gfx.set(0, 0, 0, 1)

    elm:draw()
  end

  gfx.dest = 0

end

--- Searches the layer for an element matching the given name.
-- @param name string An element name
-- @return element|nil
function Layer:findElementByName(name)
  if self.elements[name] then return self.elements[name] end
end

--- Searches the layer for any elements containing a given point.
-- @param x number
-- @param y number
-- @return element|nil
function Layer:findElementContaining(x, y)
  if self.elementCount > 0 and not (self.hidden or self.frozen) then
    for _, elm in pairs(self.elements) do
      if elm:containsPoint(x, y) then return elm end
    end
  end
end

return Layer
