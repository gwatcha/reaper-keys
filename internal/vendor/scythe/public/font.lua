--- @module Font

local Font = {}

Font.fonts = {}

--- Adds fonts to the available presets, or overrides existing ones.
-- @param fonts hash A table of preset arrays, of the form `{ presetName: { fontName, size, "biu" } }`.
Font.addFonts = function(fonts)
  for k, v in pairs(fonts) do
    Font.fonts[k] = v
  end
end

--- Applies a font preset.
-- @param fontIn string|array An existing preset (`"monospace"`, `1`) or an
-- array of font parameters: `{ fontName, size, "biu" }`.
Font.set = function (fontIn)
  local font, size, str = table.unpack( type(fontIn) == "table"
                                          and fontIn
                                          or  Font.fonts[fontIn])

  -- Different OSes use different font sizes, for some reason
  -- This should give a similar size on Mac/Linux as on Windows
  if not string.match( reaper.GetOS(), "Win") then
    size = math.floor(size * 0.8)
  end

  -- Cheers to Justin and Schwa for this
  local flags = 0
  if str then
    for i = 1, str:len() do
      flags = flags * 256 + string.byte(str, i)
    end
  end

  gfx.setfont(1, font, size, flags)

end

--- Checks if a given font exists on the current system
-- @param fontName string The name of a font.
-- @return boolean
Font.exists = function (fontName)
  if type(fontName) ~= "string" then return false end

  gfx.setfont(1, fontName, 10)
  local _, ret_font = gfx.getfont()

  return fontName == ret_font
end

return Font
