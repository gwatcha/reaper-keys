local format = require('utils.format')
local log = require('utils.log')

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
  Font.set(self.textFont)

  gfx.x, gfx.y = self.x + self.pad, self.y + self.pad
  local r = gfx.x + self.w - 2*self.pad
  local b = gfx.y + self.h - 2*self.pad

  local outputText = {}
  for i = self.windowY, math.min(self:windowBottom() - 1, #self.list) do
    local current_row = self.list[i]

    -- log.user(format.block(current_row))

    local action_name = current_row.action_name

    local index = 1
    for char in action_name:gmatch"." do
      Color.set(self.color)

      for _,matched_index in ipairs(current_row.matched_indices) do
        if index == matched_index then
          Color.set(self.match_color)
          break
        end
      end

      gfx.drawstr(self:formatOutput(char))

      index = index + 1
    end

    if current_row.main_key_binding or current_row.midi_key_binding then
      Color.set(self.color)
      gfx.drawstr(" (")

      local main_key_binding = current_row.main_key_binding
      local midi_key_binding = current_row.midi_key_binding
      if main_key_binding and midi_key_binding and main_key_binding == midi_key_binding then
        Color.set(self.global_key_binding_color)
        gfx.drawstr(self:formatOutput(main_key_binding))
      elseif main_key_binding and midi_key_binding then
        Color.set(self.main_key_binding_color)
        gfx.drawstr("")
        gfx.drawstr(self:formatOutput(main_key_binding))
        gfx.drawstr(" ")

        Color.set(self.midi_key_binding_color)
        gfx.drawstr("")
        gfx.drawstr(self:formatOutput(midi_key_binding))
        gfx.drawstr("")
      elseif main_key_binding then
        Color.set(self.main_key_binding_color)
        gfx.drawstr(self:formatOutput(main_key_binding))
      else
        Color.set(self.midi_key_binding_color)
        gfx.drawstr(self:formatOutput(midi_key_binding))
      end

      Color.set(self.color)
      gfx.drawstr(")")
    end

    -- outputText[#outputText + 1] = self:formatOutput(str)
    gfx.x = self.x + self.pad
    gfx.y = gfx.y + self.charH
  end

end


return FuzzyFinder


