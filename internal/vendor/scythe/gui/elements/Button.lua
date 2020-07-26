--- @module Button
-- It's a button. You click on it. Things happen.
-- @commonParams
-- @option caption string
-- @option font number A font preset
-- @option textColor string|table A color preset
-- @option fillColor string|table A color preset
-- @option func function Function to execute when the button is clicked.
-- @option params array Arguments that will be unpacked and passed to `func`:
--
-- `func = function(a, b, c) end`<br/>
-- `params = {1, 2, 3}`
-- @option rightFunc function Function to execute when the button is right-clicked.

local Buffer = require("public.buffer")

local Font = require("public.font")
local Color = require("public.color")
local GFX = require("public.gfx")
local Config = require("gui.config")

local Element = require("gui.element")

local Button = Element:new()
Button.__index = Button
Button.defaultProps = {
  name = "button",
  type = "Button",

  x = 0,
  y = 0,
  w = 96,
  h = 24,

  caption = "Button",
  font = 3,
  textColor = "text",
  fillColor = "elementBody",

  func = function () end,
  params = {},
  state = 0,
}


function Button:new(props)
  local button = self:addDefaultProps(props)

  return setmetatable(button, self)
end


function Button:init()
  self.buffer = self.buffer or Buffer.get()

  gfx.dest = self.buffer
  gfx.setimgdim(self.buffer, -1, -1)
  gfx.setimgdim(self.buffer, 2*self.w + 4, self.h + 2)

  Color.set(self.fillColor)
  GFX.roundRect(1, 1, self.w, self.h, 4, 1, 1)
  Color.set("elementOutline")
  GFX.roundRect(1, 1, self.w, self.h, 4, 1, 0)

  local r, g, b, a = table.unpack(Color.colors.shadow)
  gfx.set(r, g, b, 1)
  GFX.roundRect(self.w + 2, 1, self.w, self.h, 4, 1, 1)
  gfx.muladdrect(self.w + 2, 1, self.w + 2, self.h + 2, 1, 1, 1, a, 0, 0, 0, 0 )
end


function Button:onDelete()

  Buffer.release(self.buffer)

end


function Button:draw()

  local x, y, w, h = self.x, self.y, self.w, self.h
  local state = self.state

  -- Draw the shadow if not pressed
  if state == 0 and Config.drawShadows then
    for i = 1, Config.shadowSize do
      gfx.blit(self.buffer, 1, 0, w + 2, 0, w + 2, h + 2, x + i - 1, y + i - 1)
    end
  end

  gfx.blit(self.buffer, 1, 0, 0, 0, w + 2, h + 2, x + 2 * state - 1, y + 2 * state - 1)

  -- Draw the caption
  Color.set(self.textColor)
  Font.set(self.font)

  local str = self:formatOutput(self.caption)
  str = str:gsub([[\n]],"\n")

  local strWidth, strHeight = gfx.measurestr(str)
  gfx.x = x + 2 * state + ((w - strWidth) / 2)
  gfx.y = y + 2 * state + ((h - strHeight) / 2)
  gfx.drawstr(str)

end


function Button:onMouseDown()
  self.state = 1
  self:redraw()
end


function Button:onMouseUp(state)
  self.state = 0

  if self:containsPoint(state.mouse.x, state.mouse.y) and not state.preventDefault then

    self:func(table.unpack(self.params))

  end
  self:redraw()
end


function Button:onDoubleClick()

  self.state = 0

end


function Button:onRightMouseUp(state)
  if self:containsPoint(state.mouse.x, state.mouse.y) and self.rightFunc then

    self:rightFunc(table.unpack(self.rightParams))

  end
end

--- Calls a button's function programmatically
-- @option r boolean If `true`, will call the button's `rightFunc` instead.
function Button:exec(r)

  if r then
    self:rightFunc(table.unpack(self.rightParams))
  else
    self:func(table.unpack(self.params))
  end

end

return Button
