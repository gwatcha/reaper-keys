--- @module Color

local Math = require("public.math")
local Table = require("public.table")

local Color = {}

--- Applies a color preset for Reaper's gfx functions
-- @param col string|array An existing preset (`"elementBody"`, `"red"`) or an
-- array of RGBA values (0-1): `{r, g, b, a}`. If an array doesn't include a value
-- for alpha, it will default to 1.
-- @return array The RGBA values used (`{r, g, b, a}`); this may be
-- useful when applying string presets.
Color.set = function (col)
  local r, g, b, a

  -- If we're given a table of color values, just pass it right along
  if type(col) == "table" then
    r, g, b, a = table.unpack(col)
    a = a or 1
  else

    -- Recurse through the presets; allows presets to refer to other presets
    -- Should arguably have a limit to avoid infinite loops if red = "blue" = "red"...
    local val = Color.colors[col]
    while type(val) == "string" do
      val = Color.colors[val]
    end

    if not val then
      error("Couldn't find color preset: '" .. col .. "'")
    end

    r, g, b, a = table.unpack(val)
  end

  gfx.set(r, g, b, a)
  return {gfx.r, gfx.g, gfx.b, gfx.a}
end

--- Converts a color from 0-255 RGBA.
-- @param r number Red, 0-255
-- @param g number Green, 0-255
-- @param b number Blue, 0-255
-- @param a number Alpha, 0-255
-- @return array Color components, with values from 0-1. (`{r, g, b, a}`)
Color.fromRgba = function(r, g, b, a)
  if type(r) == "table" then r, g, b, a = table.unpack(r) end

  return {r / 255, g / 255, b / 255, (a and (a / 255) or 1)}
end

--- Converts a color to 0-255 RGBA.
-- @param r number Red, 0-1
-- @param g number Green, 0-1
-- @param b number Blue, 0-1
-- @param a number Alpha, 0-1
-- @return array Color components, with values from 0-255. (`{127, 51, 127, 255}`)
Color.toRgba = function(r, g, b, a)
  if type(r) == "table" then r, g, b, a = table.unpack(r) end

  return {r * 255, g * 255, b * 255, (a and (a * 255) or 1)}
end

--- Converts a color from 0-255 RGBA in hexadecimal form
-- @param hexStr string A color string of the form `FF34CA81`. The string may be
-- prefixed with `#` or `0x`, as both are very common when using hex colors.
-- @return array Color components, with values from 0-1. (`{r, g, b, a}`)
Color.fromHex = function (hexStr)

  -- Trim any "0x" or "#" prefixes
  local hex = hexStr:match("[0-9A-F]+$")

  local red, green, blue = hex:match("([0-9A-F][0-9A-F])([0-9A-F][0-9A-F])([0-9A-F][0-9A-F])")
  local alpha = (hex:len() == 8) and hex:match("([0-9A-F][0-9A-F])$")

  red = tonumber(red, 16) or 0
  green = tonumber(green, 16) or 0
  blue = tonumber(blue, 16) or 0
  alpha = alpha and tonumber(alpha, 16) or 255

  return {red / 255, green / 255, blue / 255, alpha / 255}
end

--- Converts a color to 0-255 RGBA in hexadecimal form.
-- @param r number Red, 0-1
-- @param g number Green, 0-1
-- @param b number Blue, 0-1
-- @param a number Alpha, 0-1
-- @return string A color string of the form `FF34CA81`
Color.toHex = function(r, g, b, a)
  return string.format("%02X%02X%02X", Math.round(r * 255), Math.round(g * 255), Math.round(b * 255))
      .. (a and string.format("%02X", Math.round(a * 255)) or "")
end

--- Converts a color to HSV (Hue, Saturation, Value).
-- @param r number Red, 0-1
-- @param g number Green, 0-1
-- @param b number Blue, 0-1
-- @param a number Alpha, 0-1
-- @return array `{hue, saturation, value, alpha}`. `hue` is a number from 0 to
-- 360, while the remaining values are from 0 to 1.
Color.toHsv = function (r, g, b, a)

  local max = math.max(r, g, b)
  local min = math.min(r, g, b)
  local chroma = max - min

  -- Dividing by zero is never a good idea
  if chroma == 0 then
    return {0, 0, max, (a or 1)}
  end

  local hue
  if max == r then
    hue = ((g - b) / chroma) % 6
  elseif max == g then
    hue = ((b - r) / chroma) + 2
  elseif max == b then
    hue = ((r - g) / chroma) + 4
  else
    hue = -1
  end

  if hue ~= -1 then hue = hue / 6 end

  local sat = (max ~= 0)  and ((max - min) / max)
                          or  0

  return {hue * 360, sat, max, (a or 1)}

end


--- Converts a color from HSV (Hue, Saturation, Value).
-- @param h number Hue angle, 0-360
-- @param s number Saturation, 0-1
-- @param v number Value, 0-1
-- @param a number Alpha, 0-1
-- @return array Color components, with values from 0-1. (`{r, g, b, a}`)
Color.fromHsv = function (h, s, v, a)

  -- A straight % will be wrong for h < 0
  local hue = (h % 360) / 360

  local chroma = v * s

  local hp = hue * 6
  local x = chroma * (1 - math.abs(hp % 2 - 1))

  local r, g, b
  if hp <= 1 then
    r, g, b = chroma, x, 0
  elseif hp <= 2 then
    r, g, b = x, chroma, 0
  elseif hp <= 3 then
    r, g, b = 0, chroma, x
  elseif hp <= 4 then
    r, g, b = 0, x, chroma
  elseif hp <= 5 then
    r, g, b = x, 0, chroma
  elseif hp <= 6 then
    r, g, b = chroma, 0, x
  else
    r, g, b = 0, 0, 0
  end

  local min = v - chroma

  return {r + min, g + min, b + min, (a or 1)}

end


--- Returns the color for a given position on an HSV gradient between two colors.
-- @param a string|array A preset strng, or color components with values from 0-1.
-- (`{r, g, b, a}`)
-- @param b string|array A preset strng, or color components with values from 0-1.
-- (`{r, g, b, a}`)
-- @param pos number Position along the gradient from 0-1, where 0 == `a` and 1 == `b`.
-- @return array Color components, with values from 0-1. (`{r, g, b, a}`)
Color.gradient = function (a, b, pos)

  a = Color.toHsv(
    table.unpack(
      type(a) == "table"
        and a
        or  Color.colors[a]
    )
  )

  b = Color.toHsv(
    table.unpack(
      type(b) == "table"
        and b
        or  Color.colors[b]
    )
  )

  local h = math.abs(a[1] + (pos * (b[1] - a[1])))
  local s = math.abs(a[2] + (pos * (b[2] - a[2])))
  local v = math.abs(a[3] + (pos * (b[3] - a[3])))

  local alpha = (#a == 4)
      and  (math.abs(a[4] + (pos * (b[4] - a[4]))))
      or  1

  return Color.fromHsv(h, s, v, alpha)

end

--- Adds colors to the available presets, or overrides existing ones.
-- @param colors hash A table of preset arrays, in the form `{ presetName: {r, g, b, a} }`.
-- Expects component values from 0-255.
Color.addColorsFromRgba = function (colors)
  for k, v in pairs(colors) do
    Color.colors[k] = Color.fromRgba(table.unpack(v))
  end
end

-- TODO: Tests
--- Converts a color to OS-native, for use with API functions such as `reaper.SetTrackColor`.
-- @param array Color components, with values from 0-1. (`{r, g, b, a}`)
-- @return number An OS-native color
Color.toNative = function (color)
  local colorTable = type(color) == "table" and color or Color.colors[color]
  local rgb = Table.map(colorTable, function(v) return v * 255 end)
  return reaper.ColorToNative(rgb:unpack())
end

-- TODO: Tests
--- Converts a color from OS-native, for use with API functions such as ` reaper.GetTrackColor`.
-- @param number An OS-native color
-- @return array Color components, with values from 0-1. (`{r, g, b, a}`)
Color.fromNative = function(color)
  local r, g, b = reaper.ColorFromNative(color)
  return {r / 255, g / 255, b / 255}
end

Color.colors = {
  -- Standard 16 colors
  black = Color.fromRgba(0, 0, 0, 255),
  white = Color.fromRgba(255, 255, 255, 255),
  red = Color.fromRgba(255, 0, 0, 255),
  lime = Color.fromRgba(0, 255, 0, 255),
  blue = Color.fromRgba(0, 0, 255, 255),
  yellow = Color.fromRgba(255, 255, 0, 255),
  cyan = Color.fromRgba(0, 255, 255, 255),
  magenta = Color.fromRgba(255, 0, 255, 255),
  silver = Color.fromRgba(192, 192, 192, 255),
  gray = Color.fromRgba(128, 128, 128, 255),
  maroon = Color.fromRgba(128, 0, 0, 255),
  olive = Color.fromRgba(128, 128, 0, 255),
  green = Color.fromRgba(0, 128, 0, 255),
  purple = Color.fromRgba(128, 0, 128, 255),
  teal = Color.fromRgba(0, 128, 128, 255),
  navy = Color.fromRgba(0, 0, 128, 255),

  none = Color.fromRgba(0, 0, 0, 0),
}

return Color
