-- TODO change colors to RGBA and use preset name similar to Font

local config = require('definitions.gui_config')
local gui_utils = require('gui.utils')
local scale = gui_utils.scale
local log = require('utils.log')
local format = require('utils.format')
local createCompletionsElement = require('gui.feedback.completions')
local model = require('gui.feedback.model')

local scythe = require('scythe')
local Font = require("public.font")
local Color = require("public.color")
local GUI = require('gui.core')

View = {}

function createMeasurements(props)
  Font.set("feedback_main")
  local _, char_h = gfx.measurestr("i")
  local pad = scale(props.elements.padding)
  local message_h = char_h + 2 * pad
  local mode_line_h  = scale(props.elements.mode_line_h)
  local height_no_completions = mode_line_h + message_h 
  return {
    char_h = char_h,
    pad = pad,
    message_h = message_h,
    height_no_completions = height_no_completions,
    mode_line_h = mode_line_h
  }
end

function View:updateElementDimensions()
  local m = createMeasurements(self.props)
  local window = self.window
  local completions_height = window.h - m.height_no_completions
  local elements = self.elements

  elements.completions.h = completions_height
  elements.completions.pad = m.pad
  elements.completions.w = window.w

  elements.modeline.h = m.mode_line_h
  elements.modeline.y = completions_height
  elements.modeline.w = window.w
  elements.modeline.pad = m.pad

  elements.message.y = completions_height + m.mode_line_h 
  elements.message.h = m.message_h
  elements.message.w = window.w
  elements.message.pad = m.pad
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
  local prev_window_settings = model.getKey("window_settings")
  if prev_window_settings then
    return prev_window_settings
  end

  local default_window_settings =  {
    w = scale(800),
    x = scale(500),
    y = scale(500),
    h = scale(50),
    dock = 0,
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

function View:update(model)
  for element_name,element in pairs(self.elements) do
    element:val(model[element_name])
  end
end

function View:open()
  local update_number = 0
  local function main()
    local model_data = model.get()

    if self.window.state.resized then
      self.window.state.resized = false
      self.window.h = self.window.state.currentH
      self.window.w = self.window.state.currentW
      self.window:reopen(self.getWindowSettings())
      self:updateElementDimensions()
      self:update(model_data)
    end

    if model_data.update_number ~= update_number then
      self:update(model_data)
      update_number = model_data.update_number
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

return View
