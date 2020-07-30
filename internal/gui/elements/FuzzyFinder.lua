local gui_utils = require('gui.utils')

local Buffer = require("public.buffer")
local Font = require("public.font")
local Color = require("public.color")
local Math = require("public.math")
local GFX = require("public.gfx")
local Text = require("public.text")
local Table = require("public.table")
local Listbox = require('gui.elements.Listbox')
local T = Table.T
require("public.string")

local FuzzyFinder = Listbox
FuzzyFinder.type = "FuzzyFinder"
FuzzyFinder.name = "fuzzyfinder"

function FuzzyFinder:drawText()
  gfx.x, gfx.y = self.x + self.pad, self.y + self.pad
  local r = gfx.x + self.w - 2*self.pad
  local b = gfx.y + self.h - 2*self.pad

  Font.set(self.textFont)
  local _, main_font_h = gfx.measurestr("_")

  local outputText = {}
  for i = self.windowY, math.min(self:windowBottom() - 1, #self.list) do

    local current_row = self.list[i]

    local action_name = current_row.action_name

    local index = 1
    for char in action_name:gmatch"." do
      Color.set(self.colors.action_name)

      for _,matched_index in ipairs(current_row.matched_indices) do
        if index == matched_index then
          Color.set(self.colors.matched_key)
          break
        end
      end

      gfx.drawstr(self:formatOutput(char))

      index = index + 1
    end

    local binding = current_row.binding
    if binding then
      Color.set(self.colors.action_name)
      gfx.drawstr(" (")

      if current_row.context == 'global' then
        Color.set(self.colors.global_binding)
        gfx.drawstr(self:formatOutput(binding))
      elseif current_row.context == 'midi' then
        Color.set(self.colors.midi_binding)
        gfx.drawstr(self:formatOutput(binding))
      else
        Color.set(self.colors.main_binding)
        gfx.drawstr(self:formatOutput(binding))
      end

      Color.set(self.colors.action_name)
      gfx.drawstr(")  ")
    end

    Font.set(self.aux_font)
    local action_type_color = self.colors.action_type[current_row.action_type]
    if action_type_color then
      Color.set(action_type_color)
    end

    local str_w,str_h = gfx.measurestr(current_row.action_type)
    local action_type_text_pos = self.w - str_w
    if action_type_text_pos > gfx.x then
      gfx.x = self.w - str_w
    else
      gfx.x = gfx.x + 5
    end

    local old_y = gfx.y
    gfx.y = gfx.y + (main_font_h - str_h) / 2
    gfx.drawstr(current_row.action_type)
    gfx.y = old_y

    -- outputText[#outputText + 1] = self:formatOutput(str)
    gfx.x = self.x + self.pad

    Font.set(self.textFont)
    gfx.y = gfx.y + main_font_h
  end

end


return FuzzyFinder


