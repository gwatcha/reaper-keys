local config = require('definitions.gui_config')
local log = require('utils.log')
local Font = require('public.font')

local gui_utils = {}

local hiDPIMode

function queryHiDPIMode()
  -- need to set to 1 in order for reaper to set the variable
  gfx.ext_retina = 1
  gfx.init("window to check ext_retina", w, h, dock, x, y)
  gfx.quit()

  if gfx.ext_retina == 2 then
    hiDPIMode = true
  else
    hiDPIMode = false
  end
end

function gui_utils.scale(normal_size)
  if hiDPIMode == nil then
    queryHiDPIMode()
  end

  local scale = config.gui_scale
  if hiDPIMode == true then
    scale = scale * 2
  end

  return normal_size * scale
end


function gui_utils.addFont(font, preset_name)
  local font_name = font[1]
  local font_size = font[2]
  font_size = gui_utils.scale(font_size)
  font[2] = font_size

  if Font.exists(font_name) ~= true then
    log.warn("Font '" .. font_name .. "' does not exist, using default font instead. Please specify a different font in the gui_config file.")
  end

  local font_preset = {}
  font_preset[preset_name] = font
  Font.addFonts(font_preset)
end


return gui_utils
