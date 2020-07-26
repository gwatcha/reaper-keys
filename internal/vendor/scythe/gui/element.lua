--- @module Element
-- A base class for all GUI elements. This module is typically only used by other
-- elements, and will rarely be needed for scripts that aren't implementing their
-- own.
local Table = require("public.table")
local T = Table.T

local Element = T{}
Element.__index = Element
Element.__noRecursion = true

function Element:new()
  return setmetatable(T{}, self)
end

--- Called when the script window is first opened. Used for any do-it-once
-- processing, such as assigning and filling graphics buffers. That is, elements
-- will typically draw themselves to a buffer once on `:init()` and then
-- blit/rotate/etc from it as needed to draw themselves.
function Element:init() end

-- Called whenever the element's layer is redrawn
function Element:draw() end

-- Ask for a redraw on the next update
function Element:redraw()
  self.layer.needsRedraw = true
end

-- Called on every update loop, unless the element is hidden or frozen
function Element:onUpdate() end

-- Removes the element from its parent layer and frees up any resources the
-- element had requested (e.g. graphics buffers)
function Element:delete()

  self:handleEvent("Delete", self)
  if self.layer then self.layer:remove(self) end

end

-- Called when the element is deleted.
-- Use it for freeing up buffers and anything else memorywise that this
-- element was doing
function Element:onDelete() end


-- Set or return the element's value
-- Most elements don't track their values internally in the same format as
-- their output, so it's important to use this when accessing them to ensure
-- that right behavior.
function Element:val() end




------------------------------------
-------- User Events ---------------
------------------------------------


function Element:onMouseEnter() end
function Element:onMouseLeave() end

-- Called on every update loop if the mouse is over this element.
function Element:onMouseOver() end

-- Only called once; won't repeat if the button is held
function Element:onMouseDown() end

function Element:onMouseUp() end
function Element:onDoubleClick() end

-- Will continue being called even if you drag outside the element
function Element:onDrag() end

-- Right-click
function Element:onRightMouseDown() end
function Element:onRightMouseUp() end
function Element:onRightDoubleClick() end
function Element:onRightDrag() end

-- Middle-click
function Element:onMiddleMouseDown() end
function Element:onMiddleMouseUp() end
function Element:onMiddleDoubleClick() end
function Element:onMiddleDrag() end

function Element:onWheel() end
function Element:onType() end


-- Elements like a Textbox that need to keep track of their focus
-- state may use these to e.g. update the text somewhere else
-- when the user clicks out of the box.
function Element:onGotFocus() end
function Element:onLostFocus() end

-- Called when the script window has been resized
function Element:onResize() end

function Element:handleEvent(eventName, state, last)
  local before = "before"..eventName
  if self[before] then
    self[before](self, state, last)
  end

  self["on"..eventName](self, state, last)

  local after = "after"..eventName
  if self[after] then
    self[after](self, state, last)
  end
end

function Element:update(state, last)
  self:handleEvent("Update", state, last)

  if state.resized then
    self:handleEvent("Resize", state, last)
  end
end

-- Are these coordinates inside the element?
-- If no coords are given, will use the mouse cursor
function Element:containsPoint (x, y)

  return  ( x >= (self.x or 0) and x < ((self.x or 0) + (self.w or 0)) and
            y >= (self.y or 0) and y < ((self.y or 0) + (self.h or 0)) )

end

-- Returns the x,y that would center elm1 within elm2.
-- Axis can be "x", "y", or "xy".
-- If elm2 is omitted, centers elm1 in the window instead
function Element:center (elm1, elm2)

  elm2 = elm2
    or (elm1.layer and elm1.layer.window and {
      x = 0,
      y = 0,
      w = elm1.layer.window.currentW,
      h = elm1.layer.window.currentH
    })

  if not elm2
    and (   elm2.x and elm2.y and elm2.w and elm2.h
        and elm1.x and elm1.y and elm1.w and elm1.h) then return end

  return (elm2.x + (elm2.w - elm1.w) / 2), (elm2.y + (elm2.h - elm1.h) / 2)

end


-- Returns the specified parameters for a given element.
-- If nothing is specified, returns all of the element's properties.
-- ex. local str = my_element:debug("x", "y", "caption", "textColor")
function Element:debug(...)

  local arg = {...}

  if #arg == 0 then
    arg = {}
    for k in Table.kpairs(self) do
      arg[#arg+1] = k
    end
  end

  if not self or not self.type then return end
  local pre = tostring(self.name) .. "."
  local strs = {}

  for i = 1, #arg do
    local k, v = arg[i], self[arg[i]]

    strs[#strs + 1] = pre .. tostring(k) .. " = "

    if type(v) == "table" then
      strs[#strs] = strs[#strs] .. "table:"

      -- Hacks to break infinite loops; should probably be done
      -- with some sort of override in the element classes
      -- local depth = (k == "layer" or k == "tabs") and 2
      if (k == "layer") then
        strs[#strs + 1] = Table.stringify(v, nil, 1)
      elseif (k == "tabs") then
        local tabs = {}
        for _, tab in pairs(v) do
          tabs[#tabs + 1] = "  " .. tab.label
          for _, layer in pairs(tab.layers) do
            tabs[#tabs + 1] = "    " .. layer.name .. ", z = " .. layer.z
          end
        end
        strs[#strs + 1] = table.concat(tabs, "\n")
      else
        strs[#strs + 1] = Table.stringify(v, nil, 1)
      end
    else
        strs[#strs] = strs[#strs] .. tostring(v)
    end

  end

  return table.concat(strs, "\n")
end


function Element:moveToLayer(dest)
  if self.layer then self.layer:removeElements(self) end
  if dest then dest:addElements(self) end
end

-- Most elements will accept a .output property, specifying how to display
-- their values depending on .output's type:
-- String: Returns the string, with any occurrences of '%val%' replaced by the element's value
-- Table: The element's value will be used as a key
-- Function: The element's value will be passed to it
function Element:formatOutput(val)
  if not self.output then return tostring(val) end

  local output
  local t = type(self.output)

  if t == "string" or t == "number" then
    output = self.output:gsub("%%val%%", val)
  elseif t == "table" then
    output = self.output[val]
  elseif t == "function" then
    output = self.output(val)
  end

  return output and tostring(output) or tostring(val)
end


-- Use the given table of properties to make sure the element has everything
-- needed to display it.
function Element:addDefaultProps (props)
  if type(props) ~= "table" then return props end

  local new = Table.deepCopy(props or {})

  return Table.addMissingKeys(new, self.defaultProps)
end


function Element:showDevMenu(state)
  gfx.x = state.mouse.x
  gfx.y = state.mouse.y
  local ret = gfx.showmenu("#"..self.name.."||List properties in console")
  if ret == 2 then
    Msg(self:debug())
  end
end

return Element
