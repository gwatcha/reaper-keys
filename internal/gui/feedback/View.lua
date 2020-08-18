local log = require('utils.log')
local format = require('utils.format')

local config = require('definitions.gui_config')
local gui_utils = require('gui.utils')
local scale = gui_utils.scale
local createCompletionsElement = require('gui.feedback.completions')
local createMessageElement = require('gui.feedback.message')
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
  self.message_h = message_h

  local window = self.window
  local completions_height = window.h - message_h
  local elements = self.elements

  elements.completions.h = completions_height
  elements.completions.pad = pad
  elements.completions.w = window.w

  elements.message.y = completions_height
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

  return {}
end

function createWindow(props)
  local window_settings = getWindowSettings()
  local window = GUI.createWindow({
      name = "Reaper Keys Feedback",
      w = window_settings.w,
      x = window_settings.x,
      h = window_settings.h,
      y = window_settings.y,
      dock = 0,
      corner = "TL"
  })

  local layer = createElements()
  window:addLayers(layer)

  local frame_element = GUI.findElementByName("completions")
  createCompletionsElement(frame_element, props)

  frame_element = GUI.findElementByName("message")
  createMessageElement(frame_element, props)

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
  }

  self:updateElementDimensions()

  return view
end

function View:adjustWindow()
  local completions_h = self.elements.completions:getRequiredHeight()
  local new_h = self.message_h + completions_h
  if new_h ~= self.window.h then
    -- TODO updating the window y does not work, only adjusting width and height works
    self:redraw({h = new_h})
  end
end

function View:updateCompletions(completions)
  self.elements.completions:val(completions)
  self:adjustWindow()
end

function View:updateMessage(model)
  self.elements.message:val(model.message, model.right_text, model.mode)
end

function View:open()
  local update_number = 0
  local idle_time_until_show = self.props.idle_time_until_show
  local completions_triggered = false
  local command_begin_time = reaper.time_precise()
  local command_end = true

  local function main()
    local model = model_interface.get()
    local completions = model.completions

    if model.update_number ~= update_number then
      if command_end then
        command_end = false
        command_begin_time = reaper.time_precise()
      end

      update_number = model.update_number
      self:updateMessage(model)

      if completions_triggered then
        self:updateCompletions(completions)
        if not completions or #completions == 0 then
          command_end = true
          completions_triggered = false
        end
      end
    else
      if not command_end and completions and #completions > 0 and not completions_triggered and idle_time_until_show <= reaper.time_precise() - command_begin_time  then
        completions_triggered = true
        self:updateCompletions(completions)
      end
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
