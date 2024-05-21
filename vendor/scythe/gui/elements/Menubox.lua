--- @module Menubox
-- @commonParams
-- @option options array A list of options: `{"a", "b", "c"}`. Options use the
-- same syntax as `gfx.showmenu` concerning separators, greying out, etc.
-- @option caption string
-- @option captionFont number A font preset
-- @option textFont number A font preset
-- @option captionColor string|table A color preset
-- @option textColor string|table A color preset
-- @option bg string|table A color preset
-- @option pad number Padding between the caption and the element frame
-- @option align number Alignment flags for the displayed value; see the API
-- documentation for `gfx.drawstr`
-- @option retval number The selected item index
local Buffer = require("public.buffer")

local Font = require("public.font")
local Color = require("public.color")
local Math = require("public.math")
local GFX = require("public.gfx")
local Text = require("public.text")
local Menu = require("public.menu")
local Config = require("gui.config")
local T = require("public.table").T

local Menubox = require("gui.element"):new()
Menubox.__index = Menubox
Menubox.defaultProps = {

  type = "Menubox",

  x = 0,
  y = 0,
  w = 96,
  h = 24,

  caption = "Menubox:",
  bg = "background",

  captionFont = 3,
  textFont = 4,

  captionColor = "text",
  textColor = "text",

  pad = 4,

  align = 0,

  retval = 1,

  options = {1, 2, 3},
}

function Menubox:new(props)
  local menu = self:addDefaultProps(props)

  return setmetatable(menu, self)
end


function Menubox:init()

  self.buffer = Buffer.get()

  gfx.dest = self.buffer
  gfx.setimgdim(self.buffer, -1, -1)
  gfx.setimgdim(self.buffer, 2*self.w + 4, 2*self.h + 4)

  self:drawFrame()

  if not self.noArrow then self:drawArrow() end

end


function Menubox:onDelete()

  Buffer.release(self.buffer)

end


function Menubox:draw()

  local x, y, w, h = self.x, self.y, self.w, self.h

  if self.caption and self.caption ~= "" then self:drawCaption() end


    -- Blit the shadow + frame
  if Config.drawShadows then
    for i = 1, Config.shadowSize do
      gfx.blit(self.buffer, 1, 0, w + 2, 0, w + 2, h + 2, x + i - 1, y + i - 1)
    end
  end

  gfx.blit(self.buffer, 1, 0, 0, (self.focus and (h + 2) or 0) , w + 2, h + 2, x - 1, y - 1)

  self:drawText()

end


--- Get or set the selected item
-- @option newval number The selected item index
-- @return number The selected item index
-- @return string The selected item's text
function Menubox:val(newval)

  if newval then
    self.retval = newval
    self:redraw()
  else
    return math.floor(self.retval), self.options[self.retval]
  end

end




------------------------------------
-------- Input methods -------------
------------------------------------


function Menubox:onMouseUp(state)
  if not self.focus or state.preventDefault then return end
  self.focus = false
  self:redraw()

  gfx.x, gfx.y = state.mouse.x, state.mouse.y
  local currentOption = Menu.showMenu(self.options)

  if currentOption ~= 0 then self.retval = currentOption end
end


-- This is only so that the box will light up
function Menubox:onMouseDown()
  self:redraw()
end


function Menubox:onWheel(state)

  -- Check for illegal values, separators, and submenus
  self.retval = self:validateOption(  Math.round(self.retval - state.mouse.wheelInc),
                                      Math.round((state.mouse.wheelInc > 0) and 1 or -1) )

  self:redraw()

end


------------------------------------
-------- Drawing methods -----------
------------------------------------


function Menubox:drawFrame()

  local w, h = self.w, self.h
  local r, g, b, a = table.unpack(Color.colors.shadow)
  gfx.set(r, g, b, 1)
  gfx.rect(w + 3, 1, w, h, 1)
  gfx.muladdrect(w + 3, 1, w + 2, h + 2, 1, 1, 1, a, 0, 0, 0, 0 )

  Color.set("backgroundDarkest")
  gfx.rect(1, 1, w, h)
  gfx.rect(1, w + 3, w, h)

  Color.set("elementBody")
  gfx.rect(1, 1, w, h, 0)
  if not self.noArrow then gfx.rect(1 + w - h, 1, h, h, 1) end

  Color.set("highlight")
  gfx.rect(1, h + 3, w, h, 0)
  gfx.rect(2, h + 4, w - 2, h - 2, 0)

end


function Menubox:drawArrow()

  local w, h = self.w, self.h
  gfx.rect(1 + w - h, h + 3, h, h, 1)

  Color.set("backgroundDarkest")

  -- Triangle size
  local r = 5

  local ox = (1 + w - h) + h / 2
  local oy = 1 + h / 2 - (r / 2)

  local Ax, Ay = Math.polarToCart(1/2, r, ox, oy)
  local Bx, By = Math.polarToCart(0, r, ox, oy)
  local Cx, Cy = Math.polarToCart(1, r, ox, oy)

  GFX.triangle(true, Ax, Ay, Bx, By, Cx, Cy)

  oy = oy + h + 2

  Ax, Ay = Math.polarToCart(1/2, r, ox, oy)
  Bx, By = Math.polarToCart(0, r, ox, oy)
  Cx, Cy = Math.polarToCart(1, r, ox, oy)

  GFX.triangle(true, Ax, Ay, Bx, By, Cx, Cy)

end


function Menubox:drawCaption()

  Font.set(self.captionFont)
  local strWidth, strHeight = gfx.measurestr(self.caption)

  gfx.x = self.x - strWidth - self.pad
  gfx.y = self.y + (self.h - strHeight) / 2

  Text.drawBackground(self.caption, self.bg)
  Text.drawWithShadow(self.caption, self.captionColor, "shadow")

end


function Menubox:drawText()

  -- Make sure retval hasn't been accidentally set to something illegal
  self.retval = self:validateOption(tonumber(self.retval) or 1)

  -- Strip gfx.showmenu's special characters from the displayed value
  local text = self:formatOutput(
    string.match(self.options[self.retval], "^[<!#]?(.+)")
  )

  -- Draw the text
  Font.set(self.textFont)
  Color.set(self.textColor)

  local _, strHeight = gfx.measurestr(text)
  gfx.x = self.x + 4
  gfx.y = self.y + (self.h - strHeight) / 2

  local r = gfx.x + self.w - 8 - (self.noArrow and 0 or self.h)
  local b = gfx.y + strHeight
  gfx.drawstr(text, self.align, r, b)

end




------------------------------------
-------- Input helpers -------------
------------------------------------




function Menubox:validateOption(val, dir)

  dir = dir or 1

  while true do

    -- Past the first option, look upward instead
    if val < 1 then
      val = 1
      dir = 1

    -- Past the last option, look downward instead
    elseif val > #self.options then
      val = #self.options
      dir = -1

    end

    -- Don't stop on separators, folders, or grayed-out options
    local opt = string.sub(self.options[val], 1, 1)
    if opt == "" or opt == ">" or opt == "#" then
      val = val - dir

    -- This option is good
    else
      break
    end

  end

  return val

end

return Menubox
