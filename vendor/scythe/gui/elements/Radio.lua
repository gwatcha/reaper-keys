--- @module Radio
-- A list of options from which only one can be selected.
-- @commonParams
-- @option caption string
-- @option options array `{"Option 1", "Option 2", "Option 3"}`
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

local Option = require("gui.elements.shared.option")

local Radio = setmetatable({}, {__index = Option})
Radio.__index = Radio

function Radio:new(props)
  local radio = Option:new(props)

  radio.type = "Radio"

  radio.retval, radio.state = 1, 1

  return setmetatable(radio, self)
end


function Radio:initOptions()

  local r = self.optionSize / 2

  -- Option bubble
  Color.set(self.bg)
  gfx.circle(r + 1, r + 1, r + 2, 1, 0)
  gfx.circle(3*r + 3, r + 1, r + 2, 1, 0)
  Color.set("elementBody")
  gfx.circle(r + 1, r + 1, r, 0)
  gfx.circle(3*r + 3, r + 1, r, 0)
  Color.set(self.fillColor)
  gfx.circle(3*r + 3, r + 1, 0.5*r, 1)

end


--- Gets or sets the selected option
-- @option newval number The selected option
-- @return number The selected option
function Radio:val(newval)

  if newval ~= nil then
    self.retval = newval
    self.state = newval
    self:redraw()
  else
    return self.retval
  end

end


function Radio:onMouseDown(state)
  if state.preventDefault then return end

  self.state = self:getMouseOption(state) or self.state

  self:redraw()

end


function Radio:onMouseUp(state)
  self.focus = false
  self:redraw()

  -- Bypass option for GUI Builder
  if state.preventDefault or not self.focus then
    self:redraw()
    return
  end

  -- Set the new option, or revert to the original if the cursor
  -- isn't inside the list anymore
  if self:containsPoint(state.mouse.x, state.mouse.y) then
    self.retval = self.state
  else
    self.state = self.retval
  end

end


function Radio:onDrag(state)
  if state.preventDefault then return end

  self:onMouseDown(state)
  self:redraw()

end


function Radio:onWheel(state)
  if state.preventDefault then return end

  self.state = self:getNextOption(    ( (state.mouse.wheelInc > 0) ~= self.horizontal )
                                      and -1
                                      or 1 )

  self.retval = self.state

  self:redraw()

end


function Radio:isOptionSelected(opt)

  return opt == self.state

end


function Radio:getNextOption(dir)

  local j = dir > 0 and #self.options or 1

  for i = self.state + dir, j, dir do

    if self.options[i] ~= "_" then
        return i
    end

  end

  return self.state

end

return Radio
