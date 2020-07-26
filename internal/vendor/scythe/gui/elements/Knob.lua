--- @module Knob
-- @commonParams
-- @option caption string
-- @option textColor string|table A color preset
-- @option headColor string|table A color preset
-- @option bodyColor string|table A color preset
-- @option bg string|table A color preset
-- @option captionX number Horizontal caption offset
-- @option captionY number Vertical caption offset
-- @option captionFont number A font preset
-- @option textFont number A font preset
-- @option min number Minimum value
-- @option max number Maximum value
-- @option inc number Amount to increment between steps
-- @option default number Default value
-- @option showValues boolean Show or hide the values. If a knob has too many
-- steps to be readable, consider hiding them and displaying the value elsewhere
local Buffer = require("public.buffer")
local Font = require("public.font")
local Color = require("public.color")
local Math = require("public.math")
local GFX = require("public.gfx")
local Text = require("public.text")
local Config = require("gui.config")
local Const = require("public.const")

local Knob = require("gui.element"):new()
Knob.__index = Knob
Knob.defaultProps = {
  name = "knob",
  type = "Knob",
  x = 0,
  y = 0,
  w = 64,
  caption = "Knob",
  bg = "background",
  captionX = 0,
  captionY = 0,
  captionFont = 3,
  textFont = 4,
  textColor = "text",
  headColor = "highlight",
  bodyColor = "elementBody",

  min = 0,
  max = 10,
  inc = 1,

  default = 5,

  showValues = true,
}

local KNOB_RANGE_RADIANS = 3 / 2
local KNOB_ANGLE_OFFSET_RADIANS = -5 / 4

function Knob:new(props)
  local knob = self:addDefaultProps(props)

  setmetatable(knob, self)
  knob:recalculateInternals()

  return knob
end

--- Updates internal values based on the knob's properties. If you change any of
-- `min`, `max`, or `inc` after the knob has been created, this method should be
-- called afterward
function Knob:recalculateInternals()
  self.h = self.w
  self.steps = self.steps or (math.abs(self.max - self.min) / self.inc)

  self.stepAngle = KNOB_RANGE_RADIANS / self.steps

  self.currentStep = self.default
    self.currentPct = self:percentFromStep(self.currentStep)

  self.retval = self:formatRetval(
    ((self.max - self.min) / self.steps) * self.currentStep + self.min
  )
end

function Knob:init()

  self.buffer = self.buffer or Buffer.get()

  gfx.dest = self.buffer
  gfx.setimgdim(self.buffer, -1, -1)

  -- Figure out the points of the triangle
  local r = self.w / 2
  local tipRadius = r * 1.5
  local currentAngle = 0
  local o = tipRadius + 1

  local w = 2 * tipRadius + 2

  local sideAngle = (math.acos(0.666667) / Const.PI) * 0.9

  local Ax, Ay = Math.polarToCart(currentAngle, tipRadius, o, o)
  local Bx, By = Math.polarToCart(currentAngle + sideAngle, r - 1, o, o)
  local Cx, Cy = Math.polarToCart(currentAngle - sideAngle, r - 1, o, o)

  gfx.setimgdim(self.buffer, 2*w, w)

  -- Head
  Color.set(self.headColor)
  GFX.triangle(true, Ax, Ay, Bx, By, Cx, Cy)
  Color.set("elementOutline")
  GFX.triangle(false, Ax, Ay, Bx, By, Cx, Cy)

  -- Body
  Color.set(self.bodyColor)
  gfx.circle(o, o, r, 1)
  Color.set("elementOutline")
  gfx.circle(o, o, r, 0)

  --gfx.blit(source, scale, rotation[, srcx, srcy, srcw, srch, destx, desty, destw, desth, rotxoffs, rotyoffs] )
  gfx.blit(self.buffer, 1, 0, 0, 0, w, w, w + 1, 0)
  gfx.muladdrect(w + 1, 0, w, w, 0, 0, 0, Color.colors.shadow[4])

end


function Knob:onDelete()

  Buffer.release(self.buffer)

end


function Knob:draw()
  local r = self.w / 2
  local o = {x = self.x + r, y = self.y + r}

  -- Value labels
  if self.showValues then self:drawValues(o, r) end

  if self.caption and self.caption ~= "" then self:drawCaption(o, r) end


  -- Figure out where the knob is pointing
  local currentAngle = KNOB_ANGLE_OFFSET_RADIANS + (self.currentStep * self.stepAngle)

  local blitWidth = 3 * r + 2
  local blitX = 1.5 * r

  -- Shadow
  if Config.drawShadows then
    for i = 1, Config.shadowSize do

      gfx.blit(   self.buffer, 1, currentAngle * Const.PI,
                  blitWidth + 1, 0, blitWidth, blitWidth,
                  o.x - blitX + i - 1, o.y - blitX + i - 1)

    end
  end

  -- Body
  gfx.blit(   self.buffer, 1, currentAngle * Const.PI,
              0, 0, blitWidth, blitWidth,
              o.x - blitX - 1, o.y - blitX - 1)

end


--- Get or set the knob's value
-- @option newval number The new value
-- @return number The current value
function Knob:val(newval)

  if newval then
    self:setCurrentStep(self:stepFromValue(newval))
    self:redraw()
  else
    return self.retval
  end

end


function Knob:onDrag(state, last)
  if state.preventDefault then return end

  -- Ctrl?
  local ctrl = state.kb.ctrl

  -- Multiplier for how fast the knob turns. Higher = slower
  --          Ctrl  Normal
  local adj = ctrl and 1200 or 150

  local pctChange = (last.mouse.y - state.mouse.y) / adj
  local newPct = Math.clamp(self.currentPct + pctChange, 0, 1)

  self:setCurrentPct(newPct)

  self:redraw()
end


function Knob:onDoubleClick(state)
  if state.preventDefault then return end

  self:setCurrentStep(self.default)
  self:redraw()
end


function Knob:onWheel(state)
  if state.preventDefault then return end

  local ctrl = state.kb.ctrl

  -- How many steps per wheel-step
  local fine = 1
  local coarse = math.max( Math.round(self.steps / 30), 1)

  local adj = ctrl and fine or coarse

  local currentPct = self:percentFromStep(self.currentStep)
  local pctChange = state.mouse.wheelInc * adj / self.steps
  local newPct = Math.clamp(currentPct + pctChange, 0, 1)

  self:setCurrentStep(self:stepFromPercent(newPct))

  self:redraw()

end



------------------------------------
-------- Drawing methods -----------
------------------------------------


function Knob:drawCaption(o, r)

  local cx, cy = Math.polarToCart(1/2, r * 2, o.x, o.y)

  Font.set(self.captionFont)
  local strWidth, strHeight = gfx.measurestr(self.caption)

  gfx.x, gfx.y = cx - strWidth / 2 + self.captionX, cy - strHeight / 2  + 8 + self.captionY

  Text.drawBackground(self.caption, self.bg)
  Text.drawWithShadow(self.caption, self.textColor, "shadow")

end


function Knob:drawValues(o, r)

  for i = 0, self.steps do

    local angle = (-5 / 4 ) + (i * self.stepAngle)

    -- Highlight the current value
    if i == self.currentStep then
      Color.set(self.headColor)
      Font.set({Font.fonts[self.textFont][1], Font.fonts[self.textFont][2] * 1.2, "b"})
    else
      Color.set(self.textColor)
      Font.set(self.textFont)
    end

    local output = self:formatOutput(
      self:formatRetval( i * self.inc + self.min )
    )

    if output ~= "" then
      local strWidth, strHeight = gfx.measurestr(output)
      local cx, cy = Math.polarToCart(angle, r * 2, o.x, o.y)
      gfx.x, gfx.y = cx - strWidth / 2, cy - strHeight / 2
      Text.drawBackground(output, self.bg)
      gfx.drawstr(output)
    end

  end

end




------------------------------------
-------- Value helpers -------------
------------------------------------


function Knob:setCurrentStep(step)
  self.currentStep = step
  self.currentPct = self:percentFromStep(step)
  self:setRetval()
end

function Knob:setCurrentPct(pct)
  self.currentPct = pct
  self.currentStep = self:stepFromPercent(pct)
  self:setRetval()
end

function Knob:setRetval()
  self.retval = self:formatRetval(self.inc * self.currentStep + self.min)
end

-- Really just strips trailing zeroes from 1.0, etc.
function Knob:formatRetval(val)
  return (math.floor(val) == val) and math.floor(val) or val
end

function Knob:valueFromStep(step)
  local pct = step / self.steps
  return self.min + pct * (self.max - self.min)
end

function Knob:stepFromValue(val)
  local pct = (val - self.min) / (self.max - self.min)
  return Math.round(pct * self.steps)
end

function Knob:stepFromPercent(pct)
  return Math.round(pct * self.steps)
end

function Knob:percentFromStep(step)
  return step / self.steps
end

return Knob
