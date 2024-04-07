local config = require 'definitions.gui_config'
local log = require 'utils.log'
local Color = require 'public.color'
local Font = require 'public.font'

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
    if not normal_size or not type(normal_size) == 'number' then
        log.error("tried to scale a non number: " .. debug.traceback())
        return nil
    end

    if hiDPIMode == nil then
        queryHiDPIMode()
    end

    local scale = config.gui_scale
    if hiDPIMode == true then
        scale = scale * 2
    end

    local ok, reaper_scale = reaper.get_config_var_string("uiscale")
    if not ok then reaper_scale = 1 end

    scale = scale * tonumber(reaper_scale)

    return normal_size * scale
end

function gui_utils.addFont(font, preset_name)
    font[2] = gui_utils.scale(font[2]) -- scale font_size
    local font_preset = {}
    font_preset[preset_name] = font
    Font.addFonts(font_preset)
end

function gui_utils.addFonts(fonts)
    for preset_name, font in pairs(fonts) do
        gui_utils.addFont(font, preset_name)
    end
end

function gui_utils.getWindowSettings()
    local current_dock, current_x, current_y, current_w, current_h = gfx.dock(-1, 0, 0, 0, 0)
    return {
        x = current_x,
        y = current_y,
        w = current_w,
        h = current_h,
        dock = current_dock,
    }
end

function gui_utils.styled_draw(text, text_preset, color)
    Font.set(text_preset)
    if color then
        Color.set(color)
        log.warn("No color passed for styled draw when drawing: " .. text)
    end

    gfx.drawstr(text)
end

return gui_utils
