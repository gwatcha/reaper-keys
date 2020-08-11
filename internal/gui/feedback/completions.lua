local gui_utils = require('gui.utils')
local log = require('utils.log')
local format = require('utils.format')
local scale = gui_utils.scale

local Font = require("public.font")
local Color = require("public.color")

function drawCompletions(self)
  if type(self.completions) == 'string' then
    return
  end

  local column_pad = scale(20)
  local row_pad = 0

  Font.set("feedback_main")
  local _, char_h = gfx.measurestr("i")
  gfx.x, gfx.y = self.pad + 1, self.pad + 1

  local current_row = 0
  local num_rows = self.h / (char_h + row_pad) - 1

  local column_width = 0
  local column_key_width = 0
  local column_x = gfx.x
  for i,completion in pairs(self.completions) do
    gfx.x = column_x
    gfx.y = current_row * (char_h + row_pad)

    Font.set("feedback_key")
    Color.set(self.props.colors.key)
    gfx.drawstr(completion.key_sequence)

    local key_width = gfx.x - column_x
    if key_width > column_key_width then
      column_key_width = key_width
    end

    Font.set("feedback_arrow")
    Color.set(self.props.colors.arrow)

    gfx.drawstr(" -> ")

    Font.set("feedback_main")
    local action_type_color = self.props.action_type_colors[completion.action_type]
    Color.set(action_type_color)
    if completion.folder == true then
      Font.set("feedback_folder")
      Color.set(self.props.colors.folder)
    end

    gfx.drawstr(completion.value)

    current_row = current_row + 1

    local row_width = gfx.x - column_x
    if row_width > column_width then
      column_width = row_width
    end

    if current_row >= num_rows then
      column_x = column_x + column_width + column_pad
      column_width = 0
      key_width = 0
      current_row = 0
    end
  end
end

function valCompletions(self, completions)
  if completions then
    self.completions = completions
    if self.buffer then self:init() end
    self:redraw()
  else
    return self.completions
  end
end

function makeCompletionsElement(frame_element, props)
  frame_element.props = props
  frame_element.drawText = drawCompletions
  frame_element.val = valCompletions
end

return makeCompletionsElement
