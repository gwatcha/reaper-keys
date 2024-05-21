--- @module Label
-- @commonParams
-- @option caption string
-- @option shadow  boolean Defaults to false
-- @option font    number A font preset
-- @option color   string|table A color preset
-- @option bg      string|table A color preset

local Buffer = require("public.buffer")

local Font = require("public.font")
local Color = require("public.color")
local Text = require("public.text")


local Label = require("gui.element"):new()
Label.__index = Label

Label.defaultProps = {
  name = "label",
  type = "Label",

  x = 0,
  y = 0,
  -- Placeholders; we'll get these at runtime
  w = 0,
  h = 0,

  caption = "Label",
  shadow =  false,
  font =    2,
  color =   "text",
  bg =      "background",
}


function Label:new(props)
  local label = self:addDefaultProps(props)

  return setmetatable(label, self)
end


function Label:init()

  -- We can't do font measurements without an open window
  if gfx.w == 0 then return end

  self.buffers = self.buffers or Buffer.get(2)

  Font.set(self.font)

  local output = self:formatOutput(self.caption)
  self.w, self.h = gfx.measurestr(output)

  local w, h = self.w + 4, self.h + 4

  -- Because we might be doing this mid-Draw,
  -- make sure we put this back the way we found it
  local dest = gfx.dest


  -- Keeping the background separate from the text to avoid graphical
  -- issues when the text is faded.
  gfx.dest = self.buffers[1]
  gfx.setimgdim(self.buffers[1], -1, -1)
  gfx.setimgdim(self.buffers[1], w, h)

  Color.set(self.bg)
  gfx.rect(0, 0, w, h)

  -- Text + shadow
  gfx.dest = self.buffers[2]
  gfx.setimgdim(self.buffers[2], -1, -1)
  gfx.setimgdim(self.buffers[2], w, h)

  -- Text needs a background or the antialiasing will look like shit
  Color.set(self.bg)
  gfx.rect(0, 0, w, h)

  gfx.x, gfx.y = 2, 2

  Color.set(self.color)

  if self.shadow then
    Text.drawWithShadow(output, self.color, "shadow")
  else
    gfx.drawstr(output)
  end

  gfx.dest = dest

end


function Label:onDelete()
  Buffer.release(self.buffers)
end


--- Fade a label out over a period of time, moving it to a given layer afterward,
-- or fading it in on a given layer instead.
-- @param len number Fade time, in seconds
-- @param dest layer The destination layer
-- @param curve number The "steepness" of the transition. Lower values will fade
-- more abruptly at the beginning, while higher values will fade more abruptly
-- at the end. Defaults to 3.
--
--
-- If a negative value is given, the label will be moved to the destination layer
-- immediately and faded in instead.
function Label:fade(len, dest, curve)
  if curve < 0 then self:moveToLayer(dest) end

  self.fadeParams = {
    length = len,
    dest = dest,
    start = reaper.time_precise(),
    curve = (curve or 3)
  }

  self:redraw()
end


function Label:draw()

    -- Font stuff doesn't work until we definitely have a gfx window
  if self.w == 0 then self:init() end

  local a = self.fadeParams and self:updateFadeAlpha() or 1
  if a == 0 then return end

  gfx.x, gfx.y = self.x - 2, self.y - 2

  -- Background
  gfx.blit(self.buffers[1], 1, 0)

  gfx.a = a

  -- Text
  gfx.blit(self.buffers[2], 1, 0)

  gfx.a = 1

end


function Label:val(newval)

  if newval then
    self.caption = newval
    self:init()
    self:redraw()
  else
    return self.caption
  end

end


function Label:updateFadeAlpha()

  local sign = self.fadeParams.curve > 0 and 1 or -1

  local diff = (reaper.time_precise() - self.fadeParams.start) / self.fadeParams.length
  diff = math.floor(diff * 100) / 100
  diff = diff^(math.abs(self.fadeParams.curve))

  local a = sign > 0 and (1 - (gfx.a * diff)) or (gfx.a * diff)

  self:redraw()

  -- Terminate the fade loop at some point
  if sign == 1 and a < 0.02 then
    self:moveToLayer(self.fadeParams.dest)
    self.fadeParams = nil
    return 0
  elseif sign == -1 and a > 0.98 then
    self.fadeParams = nil
    return 1
  end

  return a

end

return Label
