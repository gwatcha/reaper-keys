--- @module Checklist
-- One or more options that can be individually toggled
-- @commonParams
-- @option caption string
-- @option options array `{"Option 1", "Option 2", "Option 3"}`
-- @option selectedOptions hash Selected list options, of the form `{ 1 = true, 2 = false }`
-- @option horizontal boolean Lays the options out horizontally (defaults to `false`)
-- @option pad number Padding between the options (in pixels)
-- @option bg string|table A color preset
-- @option textColor string|table A color preset
-- @option fillColor string|table A color preset
-- @option captionFont number A font preset
-- @option textFont number A font preset
-- @option optionSize number Size of the option bubbles (in pixels)
-- @option frame boolean Draws a frame around the list.
-- @option shadow boolean Draws the caption and list text with shadows

local Color = require("public.color")
local Table = require("public.table")

local Option = require("gui.elements.shared.option")

local Checklist = setmetatable({}, {__index = Option})
Checklist.__index = Checklist

function Checklist:new(props)
  local checklist = Option:new(props)

  checklist.type = "Checklist"

  checklist.selectedOptions = checklist.selectedOptions or {}

  return setmetatable(checklist, self)
end


function Checklist:initOptions()

  local size = self.optionSize

  -- Option frame
  Color.set("elementBody")
  gfx.rect(1, 1, size, size, 0)
  gfx.rect(size + 3, 1, size, size, 0)

  -- Option fill
  Color.set(self.fillColor)
  gfx.rect(size + 3 + 0.25*size, 1 + 0.25*size, 0.5*size, 0.5*size, 1)

end


--- Gets or sets the checklist's selected options.
-- @option newval hash|boolean As a hash, sets the option state as per the class'
-- `selectedOptions` parameter above. If the checklist only has one option, a
-- boolean may be passed instead.
-- @option returnBool boolean If true, lists with only one option will have a
-- boolean value returned directly.
-- @return hash|boolean Returns the option state in the same form as the
-- `selectedOptions` parameter above, or a single value if `returnBool` is set.
function Checklist:val(newval, returnBool)

  if newval ~= nil then
    if type(newval) == "table" then
      for k, v in pairs(newval) do
        self.selectedOptions[tonumber(k)] = v
      end
    elseif type(newval) == "boolean" and #self.options == 1 then
      self.selectedOptions[1] = newval
    end
    self:redraw()
  else
    if returnBool and #self.options == 1 then
      return self.selectedOptions[1]
    else
      return Table.map(self.selectedOptions, function(val) return not not val end)
    end
  end

end


function Checklist:onMouseUp(state)
  if state.preventDefault then return end

  local mouseOption = self:getMouseOption(state)

  if not mouseOption then return end

  self.selectedOptions[mouseOption] = not self.selectedOptions[mouseOption]

  self.focus = false
  self:redraw()
end


function Checklist:isOptionSelected(opt)
  return self.selectedOptions[opt]
end

return Checklist
