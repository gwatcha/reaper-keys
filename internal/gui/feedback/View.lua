-- TODO change colors to RGBA and use preset name similar to Font
local log = require('utils.log')

local config = require('definitions.gui_config')
local gui_utils = require('gui.utils')
local scale = gui_utils.scale
local createCompletionsElement = require('gui.feedback.completions')
local model_interface = require('gui.feedback.model')

local scythe = require('scythe')
local Font = require("public.font")
local Color = require("public.color")
local GUI = require('gui.core')

View = {}

function View:updateElementDimensions()
  Font.set("feedback_main")
  local _, char_h = gfx.measurestr("i")
  local props = self.props
  local pad = scale(props.elements.padding)

  local message_h = char_h + 2 * pad
  local mode_line_h  = scale(props.elements.mode_line_h)
  local base_height = mode_line_h + message_h
  self.base_height = base_height

  local window = self.window
  local completions_height = window.h - base_height
  local elements = self.elements

  elements.completions.h = completions_height
  elements.completions.pad = pad
  elements.completions.w = window.w

  elements.modeline.h = mode_line_h
  elements.modeline.y = completions_height
  elements.modeline.w = window.w
  elements.modeline.pad = pad

  elements.message.y = completions_height + mode_line_h
  elements.message.h = message_h
  elements.message.w = window.w
  elements.message.pad = pad
end

function createElements()
  local layer = GUI.createLayer({name = "Main Layer"})
  layer:addElements( GUI.createElements(
                       {
                         type = "Frame",
                         name = "completions",
                         font = "feedback_main",
                         bg = "backgroundDarkest",
                         completions = {},
                       },
                       {
                         type = "Frame",
                         name = "modeline",
                       },
                       {
                         type = "Frame",
                         name = "message",
                         font = "feedback_main",
                       }
  ))
  return layer
end

function getWindowSettings(measurements)
  local prev_window_settings = model_interface.getKey("window_settings")
  if prev_window_settings then
    return prev_window_settings
  end

  local default_window_settings =  {
    w = scale(800),
    x = scale(500),
    y = scale(500),
    h = scale(50),
  }
  return default_window_settings
end

function createWindow(props)
  local window_settings = getWindowSettings()
  local window = GUI.createWindow({
      name = "Reaper Keys Feedback",
      w = window_settings.w,
      x = window_settings.x,
      h = window_settings.h,
      y = window_settings.y,
      dock = props.dock,
      corner = "TL"
  })

  local layer = createElements()
  window:addLayers(layer)

  local frame_element = GUI.findElementByName("completions")
  createCompletionsElement(frame_element, props)

  return window
end

function View:new()
  local view = {}
  setmetatable(view, self)
  self.__index = self
  self.props = config.feedback
  self.props.action_type_colors = config.action_type_colors
  gui_utils.addFonts(self.props.fonts)
  self.window = createWindow(self.props)
  self.elements = {
    completions = GUI.findElementByName("completions"),
    message = GUI.findElementByName("message"),
    modeline = GUI.findElementByName("modeline"),
  }

  self:updateElementDimensions()

  return view
end

function View:adjustWindow()
  local completions_h = self.elements.completions:getRequiredHeight()
  local new_h = self.base_height + completions_h
  if new_h ~= self.window.h then
    self:redraw({h = new_h})
  end
end

function View:update(model)
  self.elements.completions:val(model.completions)
  self.elements.modeline:val(model.mode)
  self.elements.message:val(model.message .. "   " .. model.right_text)
  self:adjustWindow()
end

function View:open()
  local update_number = 0
  local function main()
    local model = model_interface.get()
    if model.update_number ~= update_number then
      update_number = model.update_number
      self:update(model)
    end

    if self.window.state.resized then
      self.window.state.resized = false
      self:redraw()
    end
  end

  self.window:open()
  GUI.func = main
  GUI.funcTime = 0
  GUI.Main()
end

function View:getWindowSettings()
   return gui_utils.getWindowSettings()
end

function View:redraw(params)
  self.window:reopen(params)
  self:updateElementDimensions()
  for _,element in pairs(self.elements) do
    if element.recalculateWindow then
      element:recalculateWindow()
    end
    element:init()
    element:redraw()
  end
end

return View
