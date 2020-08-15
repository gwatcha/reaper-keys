local gui_utils = require('gui.utils')
local scale = gui_utils.scale

local Font = require('public.font')

function getMaxKeyWidth(completions)
  local max_key_width = 0
  for i,completion in pairs(completions) do
    Font.set("feedback_key")
    local key_width = gfx.measurestr(completion.key_sequence)
    if key_width > max_key_width then
      max_key_width = key_width
    end
  end

  return max_key_width
end

function table.slice(t, first, last)
  local sliced = {}

  local adjusted_last = last
  if not last or last > #t then
      adjusted_last = #t
  end

  for i = first or 1, adjusted_last, 1 do
    sliced[#sliced+1] = t[i]
  end

  return sliced
end

function drawCompletions(self)
  local completions = self.completions
  if type(completions) == 'string' then
    return
  end
  if not completions then
    return
  end

  Font.set("feedback_main")
  local _, char_h = gfx.measurestr("i")

  gfx.x = self.pad

  local row_pad = self.props.elements.row_padding
  local num_rows = math.floor((self.h - 2*self.pad) / (char_h + row_pad), 0)
  if num_rows == 0 then
    return
  end

  local num_cols = tonumber(#completions / num_rows)
  if #self.completions % num_rows > 0 then
    num_cols = num_cols + 1
  end

  local column_width = 0
  local column_pad = self.props.elements.column_padding
  local column_x = gfx.x - column_pad

  for i=1,num_cols,1 do
    local start_i = (i - 1) * num_rows + 1

    local column_completions = table.slice(completions, start_i, start_i + num_rows - 1)
    local column_max_key_width = getMaxKeyWidth(column_completions)

    column_x = column_x + column_width + column_pad
    column_width = 0

    for current_row,completion in pairs(column_completions) do
      gfx.y = (current_row - 1) * (char_h + row_pad) + self.pad
      gfx.x = column_x

      Font.set("feedback_key")
      local key_width = gfx.measurestr(completion.key_sequence)
      while gfx.x - column_x < column_max_key_width - key_width do
        gfx.drawstr(" ")
      end
      gui_utils.styled_draw(completion.key_sequence, "feedback_key", self.props.colors.key)

      gui_utils.styled_draw(" -> ", "feedback_arrow", self.props.colors.arrow)

      if completion.folder == true then
        gui_utils.styled_draw(completion.value, "feedback_folder", self.props.colors.folder)
      else
        local action_type_color = self.props.action_type_colors[completion.action_type]
        gui_utils.styled_draw(completion.value, "feedback_main", action_type_color)
      end

      local row_width = gfx.x - column_x
      if row_width > column_width then
        column_width = row_width
      end
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

function createCompletionsElement(frame_element, props)
  frame_element.props = props
  frame_element.drawText = drawCompletions
  frame_element.val = valCompletions
end

return createCompletionsElement
