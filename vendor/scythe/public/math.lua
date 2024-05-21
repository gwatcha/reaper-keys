--- @module Math

local math = math

local Const = require("public.const")

local Math = {}

--- Rounds a number to a given number of places
-- @param n number
-- @option places number Decimal places. Defaults to 0.
-- @return number
Math.round = function (n, places)
  if not places then
    return n > 0 and math.floor(n + 0.5) or math.ceil(n - 0.5)
  else
    places = 10^places

    return n > 0 and math.floor(n * places + 0.5)
                  or math.ceil(n * places - 0.5) / places
  end
end

--- Rounds a number to the nearest multiple of a given value
-- @param n number
-- @param snap number Base value for multiples
-- @return number
Math.nearestMultiple = function (n, snap)
  local int, frac = math.modf(n / snap)

  return (math.floor( frac + 0.5 ) == 1 and int + 1 or int) * snap
end


--- Clamps a number to a given range. The returned value is also the median of
-- the three values. The order of values given doesn't matter.
-- @param a number
-- @param b number
-- @param c number
-- @return number
Math.clamp = function (a, b, c)
  if b > c then b, c = c, b end

  return math.min(math.max(a, b), c)
end


--- Converts a number to an ordinal string (i.e. `30` to `30th`)
-- @param n number
-- @return string
Math.ordinal = function (n)
  n = Math.round(n)

  local endings2 = {
    ["11"] = "th",
    ["13"] = "th",
  }

  local endings1 = {
    ["1"] = "st",
    ["2"] = "nd",
    ["3"] = "rd",
  }

  local str = tostring(n)
  local ending
  if endings2[str:sub(-2)] then
    ending = endings2[str:sub(-2)]
  elseif endings1[str:sub(-1)] then
    ending = endings1[str:sub(-1)]
  else
    ending = "th"
  end

  return n .. ending
end


--- Converts an angle and radius to Cartesian coordinates
-- @param angle number Angle in radians, omitting Pi. (i.e. for Pi/4, pass `0.25`)
-- @param radius number
-- @option ox number X value of the origin point; returned coordinates
-- will be shifted by this amount. Defaults to 0.
-- @option oy number Y value of the origin point; returned coordinates
-- will be shifted by this amount. Defaults to 0.
-- @return number X value
-- @return number Y value
Math.polarToCart = function (angle, radius, ox, oy)
  local theta = angle * Const.PI
  local x = radius * math.cos(theta)
  local y = radius * math.sin(theta)

  if ox and oy then x, y = x + ox, y + oy end

  return x, y
end


--- Converts Cartesian coordinates to an angle and radius.
-- @param x number
-- @param y number
-- @option ox number X value of the origin point; The original coordinates
-- will be shifted by this amount prior to conversion. Defaults to 0.
-- @option oy number Y value of the origin point; The original coordinates
-- will be shifted by this amount prior to conversion. Defaults to 0.
-- @return angle number Angle in radians, omitting Pi. (i.e. for Pi/4, returns `0.25`)
-- @return radius number
Math.cartToPolar = function (x, y, ox, oy)
  local dx, dy = x - (ox or 0), y - (oy or 0)

  local angle = math.atan(dy, dx) / Const.PI
  local r = math.sqrt(dx * dx + dy * dy)

  return angle, r
end

return Math
