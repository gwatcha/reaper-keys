local gui_utils = require('gui.utils')
local log = require('utils.log')
local scale = gui_utils.scale
require("public.string")

local Font = require('public.font')

function drawMessage(self)
  if not self.message or not self.extra_info or not self.mode then
    return
  end

  gfx.x, gfx.y = self.pad + 1, self.pad + 1
  gui_utils.styled_draw(self.message, "feedback_main", "text")

  if self.extra_info ~= "" then
    gui_utils.styled_draw("  " .. self.extra_info, "feedback_main", self.props.colors.extra_info)
  end

  if self.mode ~= "normal" then
    local mode_str_w = gfx.measurestr(self.mode)
    gfx.x = self.w - mode_str_w - self.pad
    gui_utils.styled_draw(self.mode, "feedback_main", self.props.colors[self.mode])
  end
end

function valMessage(self, message, extra_info, mode)
  self.message = message
  self.extra_info = extra_info
  self.mode = mode

  if self.buffer then self:init() end
  self:redraw()
end

function createMessageElement(frame_element, props)
  frame_element.props = props
  frame_element.val = valMessage
  frame_element.drawText = drawMessage
end

return createMessageElement
