local config = require('definitions.config')

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

return gui_utils
