local Config = {}

Config.doubleclickTime = 0.30

--[[
    How fast the caret in textboxes should blink, measured in GUI update loops.

    '16' looks like a fairly typical textbox caret.

    Because each On and Off redraws the textbox's layer, this can cause CPU
    issues in scripts with lots of drawing to do. In that case, raising it to
    24 or 32 will still look alright but require less redrawing.
]]--
Config.caretBlinkRate = 16

-- Global shadow size, in pixels
Config.shadowSize = 1
Config.drawShadows = true

-- Delay time when hovering over an element before displaying a tooltip
Config.tooltipTime = 0.7

-- Developer mode settings
Config.dev = {

  -- gridMajor must be a multiple of gridMinor
  gridMajor = 128,
  gridMinor = 16

}



local ext = reaper.GetExtState("Scythe v3", "userConfig")

local function parseQueryString(str)
  return str:split("&"):reduce(function(acc, param)
    local k, v = param:match("([^=]+)=([^=]+)")
    if k and v then acc[k] = v end

    return acc
  end, {})
end

local userConfig = parseQueryString(ext)

for k, v in pairs(userConfig) do
  if Config[k] ~= nil then
    local parsed
    if tonumber(v) then
      parsed = tonumber(v)
    elseif v == "true" then
      parsed = true
    elseif v == "false" then
      parsed = false
    else
      parsed = v
    end

    Config[k] = parsed
  end
end

return Config
