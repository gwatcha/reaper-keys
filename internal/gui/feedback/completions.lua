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

function getCompletionPositions(self)
  local positions = {}
  local completions = self.completions
  if not completions then
    return positions, 0
  end

  Font.set("feedback_main")
  local _, char_h = gfx.measurestr("i")

  local row_pad = self.props.elements.row_padding
  local num_rows = math.floor((self.h - 2*self.pad) / (char_h + row_pad), 0)
  if num_rows == 0 then
    return positions, 0
  end

  local num_cols = tonumber(#completions / num_rows)
  if #self.completions % num_rows > 0 then
    num_cols = num_cols + 1
  end

  local column_width = 0
  local column_pad = self.props.elements.column_padding
  local column_x = column_pad
  local required_w = 0

  for i=1,num_cols,1 do
    local start_i = (i - 1) * num_rows + 1

    local column_completions = table.slice(completions, start_i, start_i + num_rows - 1)
    local column_max_key_width = getMaxKeyWidth(column_completions)

    column_x = column_x + column_width + column_pad
    column_width = 0

    for current_row,completion in pairs(column_completions) do
      Font.set("feedback_key")
      local key_width = gfx.measurestr(completion.key_sequence)

      local row_width = column_max_key_width
      Font.set("feedback_arrow")
      row_width = row_width + gfx.measurestr(" -> ")
      if completion.folder == true then
        Font.set("feedback_folder")
        row_width = row_width + gfx.measurestr(completion.value)
      else
        Font.set("feedback_main")
        row_width = row_width + gfx.measurestr(completion.value)
      end

      local position = {
        x = column_x + (column_max_key_width - key_width),
        y = (current_row - 1) * (char_h + row_pad) + self.pad,
      }
      table.insert(positions, position)

      if row_width > column_width then
        column_width = row_width
      end
    end
  end

  local required_w = column_x + column_width
  return positions, required_w
end

function drawCompletions(self)
  local completions = self.completions
  if type(completions) == 'string' then
    return
  end
  if not completions then
    return
  end

  local positions = self:getCompletionPositions()
  for i,position in pairs(positions) do
    local completion = completions[i]
    gfx.x = position.x
    gfx.y = position.y
    gui_utils.styled_draw(completion.key_sequence, "feedback_key", self.props.colors.key)
    gui_utils.styled_draw(" -> ", "feedback_arrow", self.props.colors.arrow)
    if completion.folder == true then
      gui_utils.styled_draw(completion.value, "feedback_folder", self.props.colors.folder)
    else
      local action_type_color = self.props.action_type_colors[completion.action_type]
      gui_utils.styled_draw(completion.value, "feedback_main", action_type_color)
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

function getRequiredHeight(self)
  if not self.completions or #self.completions == 0 then
    return 0
  end

  local current_h = self.h
  Font.set("feedback_main")

  local _, char_h = gfx.measurestr("i")
  local row_pad = self.props.elements.row_padding

  local x,y = self.pad, self.pad

  local row_size = char_h + row_pad
  local num_rows = 1

  local max_width = self.w
  local positions
  repeat
    num_rows = num_rows * 2
    local test_h = num_rows * row_size + self.pad * 2
    self.h = test_h
    _, required_w = self:getCompletionPositions()
  until( required_w < max_width )

  repeat
    num_rows = num_rows - 1
    local test_h = num_rows * row_size + self.pad * 2
    self.h = test_h
    _, required_w = self:getCompletionPositions()
  until( required_w > max_width or required_w == 0)
  num_rows = num_rows + 1

  self.h = current_h
  return num_rows * row_size + self.pad * 2
end

function createCompletionsElement(frame_element, props)
  frame_element.props = props
  frame_element.drawText = drawCompletions
  frame_element.val = valCompletions
  frame_element.getRequiredHeight = getRequiredHeight
  frame_element.getCompletionPositions = getCompletionPositions
end

return createCompletionsElement
