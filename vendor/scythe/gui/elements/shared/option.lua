local Buffer = require("public.buffer")
local Font = require("public.font")
local Color = require("public.color")
local Math = require("public.math")
local Text = require("public.text")
-- local Table = require("public.table")

local Option = require("gui.element"):new()
Option.__index = Option

Option.defaultProps = {
  name = "option",

  x = 0,
  y = 0,
  w = 128,
  h = 128,

  caption = "Option: ",

  bg = "background",

  horizontal = false,
  pad = 4,

  textColor = "text",
  fillColor = "highlight",

  captionFont = 2,
  textFont = 3,

  -- Size of the option bubbles
  optionSize = 20,

  options = {"Option 1", "Option 2", "Option 3"},

  frame = true,
  shadow = true,

}

function Option:new(props)

  local option = self:addDefaultProps(props, self.defaultProps)
  return setmetatable(option, self)

end


function Option:init()

  -- Make sure we're not trying to use the base class.
  -- It shouldn't be possible to get this far, but just in case...
  if self.type == "Option" then
      error("Invalid GUI class - '" .. self.name .. "' was initialized as an Option element")
      return
  end

  self.buffer = self.buffer or Buffer.get()

  gfx.dest = self.buffer
  gfx.setimgdim(self.buffer, -1, -1)
  gfx.setimgdim(self.buffer, 2*self.optionSize + 4, 2*self.optionSize + 2)

  self:initOptions()

  if self.caption and self.caption ~= "" then
    Font.set(self.captionFont)
    local strWidth, strHeight = gfx.measurestr(self.caption)
    self.captionHeight = 0.5*strHeight
    self.captionX = self.x + (self.w - strWidth) / 2
  else
    self.captionHeight = 0
    self.captionX = 0
  end

end


function Option:onDelete()

  Buffer.release(self.buffer)

end


function Option:draw()

  if self.frame then
    Color.set("elementBody")
    gfx.rect(self.x, self.y, self.w, self.h, 0)
  end

  if self.caption and self.caption ~= "" then self:drawcaption() end

  self:drawOptionBubbles()

end




------------------------------------
-------- Input helpers -------------
------------------------------------


function Option:getMouseOption(state)

  local len = #self.options

  -- See which option it's on
  local mouseOption = self.horizontal
                and (state.mouse.x - (self.x + self.pad))
                or  (state.mouse.y - (self.y + self.captionHeight + 1.5*self.pad) )

  mouseOption = mouseOption / ((self.optionSize + self.pad) * len)
  mouseOption = Math.clamp( math.floor(mouseOption * len) + 1 , 1, len )

  return self.options[mouseOption] ~= "_" and mouseOption or false

end




------------------------------------
-------- Drawing methods -----------
------------------------------------


function Option:drawcaption()

  Font.set(self.captionFont)

  gfx.x = self.captionX
  gfx.y = self.y - self.captionHeight

  Text.drawBackground(self.caption, self.bg)

  Text.drawWithShadow(self.caption, self.textColor, "shadow")

end


function Option:drawOptionBubbles()
  local pad = self.pad

  -- Bump everything down for the caption
  local adjustedY = self.y + (
    (self.caption and self.caption ~= "") and self.captionHeight or 0
  ) + 1.5 * pad

  -- Bump the options down in horizontal mode with the text on top
  if self.horizontal and self.caption ~= "" and not self.swap then
    adjustedY = adjustedY + self.captionHeight + 2*pad
  end

  local offset = self.optionSize + pad

  local x, y

  for i = 1, #self.options do
    if self.options[i] ~= "_" then

      x = self.x + (
        self.horizontal  and (i - 1) * offset + pad
                         or  (self.swap  and (self.w - offset - 1)
                                         or   pad)
      )

      y = adjustedY + (i - 1) * (self.horizontal and 0 or offset)

      self:drawOptionBubble(x, y, self.optionSize, self:isOptionSelected(i))
      self:drawOptionText(x, y, self.optionSize, self.options[i])
    end

  end

end


function Option:drawOptionBubble(x, y, size, selected)

  gfx.blit(   self.buffer, 1,  0,
              selected and (size + 3) or 1, 1,
              size + 1, size + 1,
              x, y)

end


function Option:drawOptionText(x, y, size, str)

  if not str or str == "" then return end

  Font.set(self.textFont)

  local output = self:formatOutput(str)

  local strWidth, strHeight = gfx.measurestr(output)

  if self.horizontal then

    gfx.x = x + (size - strWidth) / 2
    gfx.y = y + (self.swap and (size + 4) or -size)

  else

    gfx.x = x + (self.swap and -(strWidth + 8) or 1.5*size)
    gfx.y = y + (size - strHeight) / 2

  end

  Text.drawBackground(output, self.bg)
  if #self.options == 1 or self.shadow then
    Text.drawWithShadow(output, self.textColor, "shadow")
  else
    Color.set(self.textColor)
    gfx.drawstr(output)
  end

end

return Option
