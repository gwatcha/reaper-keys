--- @module Text

local Font = require("public.font")
local Color = require("public.color")
local Config = require("gui.config")
require("public.string")
local Table = require("public.table")
local T = Table.T

local Text = {}

--- Iterates through all of the font presets, storing the widths of every printable
-- ASCII character in a table. Widths are directly accessable via:
--
-- ```lua
-- Text.textWidth[font_num][char_num]
-- ```
--
-- Notes:
--
-- - Requires a window to have been opened in Reaper
-- - 'getTextWidth' and 'wrapText' will automatically run this
Text.initTextWidth = function ()

  Text.textWidth = {}
  local arr
  for k in pairs(Font.fonts) do

    Font.set(k)
    Text.textWidth[k] = {}
    arr = {}

    for i = 1, 255 do

      arr[i] = gfx.measurechar(i)

    end

    Text.textWidth[k] = arr

  end

end


--- Returns the total width of a given string and font. Most of the time it's
-- simpler to use `gfx.measurestr()`, but scripts with a lot of text may find it
-- more performant to use this instead.
-- @param str string
-- @param font number|string A font preset
-- @return number Width, in pixels.
Text.getTextWidth = function (str, font)

  if not Text.textWidth then Text.initTextWidth() end

  local widths = Text.textWidth[font]

  return Table.reduce(str:split("."),
    function(acc, cur)
      return acc + widths[ string.byte(cur) ]
    end,
    0
  )
end


--- Measures a string to see how much of it will it in the given width
-- @param str string
-- @param font number|string A font preset
-- @param w number Width, in pixels.
-- @return string The portion of `str` that will fit within `w`
-- @return string The portion of `str` that will not fit within `w`
Text.fitTextWidth = function (str, font, w)
  -- Assuming 'i' is the narrowest character, get an upper limit to save time
  local maxEnd = math.floor( w / Text.textWidth[font][string.byte("i")] )

  for i = maxEnd, 1, -1 do

    if Text.getTextWidth( string.sub(str, 1, i), font ) < w then

      return string.sub(str, 1, i), string.sub(str, i + 1)

    end

  end

  -- Worst case: not even one character will fit
  -- If this actually happens you should probably rethink your choices in life.
  return "", str
end


--- Wraps a string with new lines until it can fit within a given width
--
-- This function expands on the "greedy" algorithm found here:
-- https://en.wikipedia.org/wiki/Line_wrap_and_wrapText#Algorithm
-- @param str string Can include line breaks/paragraphs; they should be preserved.
-- @param font string|number A font preset
-- @param w number Width, in pixels
-- @option indent number Number of spaces to indent the first line of each
-- paragraph. Defaults to 0.
--
-- (The algorithm skips tab characters and leading spaces, so use this instead)
-- @option pad number Indents wrapped lines to match the first `pad` characters
-- of a paragraph, for use with bullet point, etc. Defaults to 0.
-- @return string The wrapped string
Text.wrapText = function (str, font, w, indent, pad)

  if not Text.textWidth then Text.initTextWidth() end

  local ret = T{}

  local widthLeft, widthWord
  local space = Text.textWidth[font][string.byte(" ")]

  local newParagraph = indent and string.rep(" ", indent) or 0

  local widthPad = pad and Text.getTextWidth( string.sub(str, 1, pad), font )
                       or 0
  local newLine = "\n"..string.rep(" ", math.floor(widthPad / space))

  str:splitLines():forEach(function(line)

    ret:insert(newParagraph)

    -- Check for leading spaces and tabs
    local leading, rest = string.match(line, "^([%s\t]*)(.*)$")
    if leading then ret:insert(leading) end

    widthLeft = w
    rest:split("%s"):forEach(function(word)
      widthWord = Text.getTextWidth(word, font)
      if (widthWord + space) > widthLeft then

        ret:insert(newLine)
        widthLeft = w - widthWord

      else

        widthLeft = widthLeft - (widthWord + space)

      end

      ret:insert(word)
      ret:insert(" ")

    end)

    ret:insert("\n")

  end)

  ret:remove(#ret)

  return table.concat(ret)

end


--- Draws a string with the specified text and shadow colors. The shadow
-- will be drawn at 45' to the bottom-right.
-- @param str string
-- @param textColor number|string A color preset
-- @param shadowColor number|string A color preset
Text.drawWithShadow = function (str, textColor, shadowColor)

  local x, y = gfx.x, gfx.y

  if Config.drawShadows then
    Color.set(shadowColor or "shadow")
    for i = 1, Config.shadowSize do
        gfx.x, gfx.y = x + i, y + i
        gfx.drawstr(str)
    end
  end

  Color.set(textColor)
  gfx.x, gfx.y = x, y
  gfx.drawstr(str)

end


--- Draws a string with the specified text and outline colors.
-- @param str string
-- @param textColor number|string A color preset
-- @param outlineColor number|string A color preset
Text.drawWithOutline = function (str, textColor, outlineColor)

  local x, y = gfx.x, gfx.y

  Color.set(outlineColor)

  gfx.x, gfx.y = x + 1, y + 1
  gfx.drawstr(str)
  gfx.x, gfx.y = x - 1, y + 1
  gfx.drawstr(str)
  gfx.x, gfx.y = x - 1, y - 1
  gfx.drawstr(str)
  gfx.x, gfx.y = x + 1, y - 1
  gfx.drawstr(str)

  Color.set(textColor)
  gfx.x, gfx.y = x, y
  gfx.drawstr(str)

end


--- Draws a background rectangle for a given string. A solid background is
-- necessary for blitting some elements; antialiased text with a transparent
-- background looks terrible. This function draws a rectangle 2px larger than
-- the text on all sides.
--
-- Call with your position, font, and color already set:
--
-- ```lua
-- gfx.x, gfx.y = self.x, self.y
-- Font.set(self.font)
-- Color.set(self.col)
--
-- Text.drawBackground(self.text)
--
-- gfx.drawstr(self.text)
--
-- Also accepts an optional background color:
-- Text.drawBackground(self.text, "backgroundDarkest")
-- ```
-- @param str string
-- @param color number|string A color preset
-- @param align number Alignment flags. See the documentation for `gfx.drawstr()`.
Text.drawBackground = function (str, color, align)

  local x, y = gfx.x, gfx.y
  local r, g, b, a = gfx.r, gfx.g, gfx.b, gfx.a

  color = color or "background"

  Color.set(color)

  local w, h = gfx.measurestr(str)
  w, h = w + 4, h + 4

  if align then

    if align & 1 == 1 then
      gfx.x = gfx.x - w/2
    elseif align & 4 == 4 then
      gfx.y = gfx.y - h/2
    end

  end

  gfx.rect(gfx.x - 2, gfx.y - 2, w, h, true)

  gfx.x, gfx.y = x, y

  gfx.set(r, g, b, a)

end

return Text
