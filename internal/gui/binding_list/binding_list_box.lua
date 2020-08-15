local gui_utils = require('gui.utils')
local log = require('utils.log')
local config = require('definitions.gui_config')
local list_config = config.binding_list
local scale = gui_utils.scale

local Color = require('public.color')
local Font = require('public.font')

function drawText(self)
  gfx.x, gfx.y = self.x + self.pad, self.y + self.pad

  Font.set("binding_list_main")
  local _, main_font_h = gfx.measurestr("_")

  local outputText = {}
  for i = self.windowY, math.min(self:windowBottom() - 1, #self.list) do
    local current_row = self.list[i]

    local action_name = current_row.action_name

    local index = 1
    for char in action_name:gmatch"." do
      Color.set(list_config.colors.action_name)
      for _,matched_index in ipairs(current_row.matched_indices) do
        if index == matched_index then
          Color.set(list_config.colors.matched_key)
          break
        end
      end

      gfx.drawstr(self:formatOutput(char))

      index = index + 1
    end

    local binding = current_row.action_binding
    if binding then
      Color.set(list_config.colors.action_name)
      gfx.drawstr(" (")
      Color.set(list_config.colors.bindings[current_row.context])
      gfx.drawstr(self:formatOutput(binding))
      Color.set(list_config.colors.action_name)
      gfx.drawstr(")  ")
    end

    Font.set("binding_list_label")
    local action_type_color = config.action_type_colors[current_row.action_type]
    if action_type_color then
      Color.set(action_type_color)
    end

    local str_w,str_h = gfx.measurestr(current_row.action_type)
    local action_type_text_pos = self.w - str_w
    if action_type_text_pos > gfx.x then
      gfx.x = self.w - self.pad - str_w
    else
      gfx.x = gfx.x + 5
    end

    local old_y = gfx.y
    gfx.y = gfx.y + (main_font_h - str_h) / 2
    gfx.drawstr(current_row.action_type)
    gfx.y = old_y

    gfx.x = self.x + self.pad

    Font.set("binding_list_main")
    gfx.y = gfx.y + main_font_h
  end

  Font.set("binding_list_label")
  Color.set(list_config.colors.count)
  gfx.y = gfx.y + self.pad / 2
  gfx.drawstr(#self.list)
  gfx.drawstr(" bindings")
end

function createBindingListBoxElement(list_box_element, props)
  list_box_element.list = {}
  list_box_element:val(1)
  list_box_element.drawText = drawText
end

return createBindingListBoxElement
