--- @module Sprite
-- _Under construction; some functionality may be missing or broken_
--
-- The Sprite class simplifies a number of common image use-cases, such as
-- working with sprite sheets (image files with multiple frames). (Only horizontal
-- sheets are currently supported)
-- @option translate hash Image offset values, of the form `{ x = 0, y = 0 }`
-- @option scale number Image size muliplier
-- @option rotate hash Rotation value, of the form `{ angle = 0, unit = "pct" }`.
-- The available units are _pct_, _deg_, and _rad_.
-- @option frame hash Frame dimensions, of the form `{ w = 0, h = 0 }`. Used in
-- conjunction with the `:draw` method's `state` argument to determine the source
-- area of the sprite's image to draw. If omitted, the entire image will be used.
-- @option image hash An image of the form `{ path = "path/img.png", buffer = 5 }`,
-- such as those returned by the Image module's loading functions.
-- @option drawBounds boolean For debugging purposes. Draws a border around the
-- image.

local Table = require("public.table")
local Image = require("public.image")
local Buffer = require("public.buffer")
local Color = require("public.color")

local sharedBuffer = Buffer.get()

local Sprite = {}
Sprite.__index = Sprite

local defaultProps = {
  translate = {x = 0, y = 0},
  scale = 1,
  rotate = {
    angle = 0,
    unit = "pct",
    -- Rotation origin is disabled until I can implement it properly
    -- Relative to the image's center (i.e. -w/2 = the top-left corner)
    -- origin = {x = 0, y = 0},
  },
  frame = {
    w = 0,
    h = 0,
  },
  image = {},
  drawBounds = false,
}

function Sprite:new(props)
  local sprite = Table.deepCopy(props)
  Table.addMissingKeys(sprite, defaultProps)
  if props.image then
    sprite.image = {}
    Sprite.setImage(sprite, props.image)
  end
  return setmetatable(sprite, self)
end

--- Sets the sprite's image via filename or a graphics buffer
-- @param val string|number If a string is passed, it will be used as a file path
-- from which to load the image. If a number is passed, the sprite will use that
-- graphics buffer and set its path to the image assigned there.
function Sprite:setImage(val)
  if type(val) == "string" then
    self.image.path = val
    self.image.buffer = Image.load(val)
  else
    self.image.buffer = val
    self.image.path = Image.getPathFromBuffer(val)
  end

  self.image.w, self.image.h = gfx.getimgdim(self.image.buffer)
end

local angleUnits = {
  deg = 1,
  rad = 1,
  pct = 2 * math.pi,
}

--- Draws the sprite
-- @param x number
-- @param y number
-- @option frame number In conjunction with the sprite's frame.w and frame.h
-- values, determines the source area to draw. Frames are counted from left to
-- right, starting at 0.
function Sprite:draw(x, y, frame)
  if not self.image.buffer then
    error("Unable to draw sprite - no image has been assigned to it")
  end

  local rotate = self.rotate.angle * angleUnits[self.rotate.unit]

  local srcX, srcY = self:getFrame(frame)
  local srcW, srcH
  if self.frame.w > 0 then
    srcW, srcH = self.frame.w, self.frame.h
  else
    srcW, srcH = self.image.w, self.image.h
  end

  local destX, destY = x + self.translate.x, y + self.translate.y

  local rotX, rotY = 0, 0 -- Rotation origin; forcing to 0 until it can be properly implemented

  local halfW, halfH = 0.5 * srcW, 0.5 * srcH
  local doubleW, doubleH = 2 * srcW, 2 * srcH

  local dest = gfx.dest
  gfx.dest = sharedBuffer
  gfx.setimgdim(sharedBuffer, -1, -1)
  gfx.setimgdim(sharedBuffer, doubleW, doubleH)
  gfx.blit(
    self.image.buffer, 1, 0,
    srcX, srcY, srcW, srcH,
    halfW, halfH, srcW, srcH,
    0, 0
  )
  gfx.dest = dest

  -- For debugging purposes
  if self.drawBounds then
    Color.set("magenta")
    gfx.rect(destX, destY, srcW * self.scale, srcH * self.scale, false)
  end

  gfx.blit(
    sharedBuffer,                               -- source
    1,                                          -- scale
    -- TODO: 2*pi is necessary to avoid issues when crossing 0, I think? Find a better solution.
    rotate + 6.2831854,                         -- rotation
    0,                                          -- srcx
    0,                                          -- srcy
    doubleW,                                    -- srcw
    doubleH,                                    -- srch
    destX + ((rotX - halfW) * self.scale),      -- destx
    destY + ((rotY - halfH) * self.scale),      -- desty
    doubleW * self.scale,                       -- destw
    doubleH * self.scale,                       -- desth
    rotX,                                       -- rotxoffs
    rotY                                        -- rotyoffs
  )
end

-- Defaults to a horizontal set of frames. Override with a custom function for more
-- complex sprite behavior.
function Sprite:getFrame(frame)
  if self.frame.w == 0 or not frame then return 0, 0 end

  return frame * self.frame.w, 0
end

return Sprite
