--- @module GFX

local GFX = {}

--- A wrapper for Reaper's roundrect() function with fill, adapted from mwe's EEL
-- example.
-- @param x number
-- @param y number
-- @param w number
-- @param h number
-- @param r number Corner radius
-- @option antialias boolean Defaults to `true`
-- @option fill boolean Defaults to `false`
GFX.roundRect = function (x, y, w, h, r, antialias, fill)

  local aa = antialias or 1
  fill = fill or 0

  if fill == 0 or false then
    gfx.roundrect(x, y, w, h, r, aa)
  else

    if h >= 2 * r then

      -- Corners
      gfx.circle(x + r, y + r, r, 1, aa)            -- top-left
      gfx.circle(x + w - r, y + r, r, 1, aa)        -- top-right
      gfx.circle(x + w - r, y + h - r, r , 1, aa)   -- bottom-right
      gfx.circle(x + r, y + h - r, r, 1, aa)        -- bottom-left

      -- Ends
      gfx.rect(x, y + r, r, h - r * 2)
      gfx.rect(x + w - r, y + r, r + 1, h - r * 2)

      -- Body + sides
      gfx.rect(x + r, y, w - r * 2, h + 1)

    else

      r = (h / 2 - 1)

      -- Ends
      gfx.circle(x + r, y + r, r, 1, aa)
      gfx.circle(x + w - r, y + r, r, 1, aa)

      -- Body
      gfx.rect(x + r, y, w - (r * 2), h)

    end

  end

end

--- A wrapper for Reaper's triangle() function with the option to not fill the shape.
-- @param fill boolean
-- @param ... number A series of X and Y values defining the vertices of the shape.
GFX.triangle = function (fill, ...)

  -- Pass any calls for a filled triangle on to the original function
  if fill then

    gfx.triangle(...)

  else

    local coords = {...}

    -- Duplicate the first pair at the end, so the last line will
    -- be drawn back to the starting point.
    table.insert(coords, coords[1])
    table.insert(coords, coords[2])

    -- Draw a line from each pair of coords to the next pair.
    for i = 1, #coords - 2, 2 do

      gfx.line(coords[i], coords[i+1], coords[i+2], coords[i+3])

    end

  end

end

return GFX
