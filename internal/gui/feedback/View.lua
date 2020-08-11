-- TODO change colors to RGBA and use preset name similar to Font

local config = require('definitions.gui_config')
local reaper_io = require('utils.reaper_io')
local gui_utils = require('gui.utils')
local scale = gui_utils.scale
local log = require('utils.log')
local format = require('utils.format')
local model_interface = require('gui.feedback.model_interface')

local scythe = require('scythe')
local Font = require("public.font")
local Color = require("public.color")
local GUI = require('gui.core')


View = {}

function createElements(props, window)
  local pad = scale(props.padding)
  Font.set("feedback_main")
  local _, char_h = gfx.measurestr("i")
  local mode_line_h = scale(props.mode_line_h)
  local message_h = char_h + 2 * pad
  local height_no_completions = mode_line_h + message_h + 2 * pad

  local layer = GUI.createLayer({name = "Main Layer"})
  layer:addElements( GUI.createElements(
                       {
                         type = "Frame",
                         name = "completions",
                         round = 5,
                         font = "feedback_main",
                         x = pad,
                         y = pad,
                         bg = "backgroundDarkest",
                         h = 0,
                         w = window.w - 2 * pad,
                       },
                       {
                         type = "Frame",
                         name = "modeline",
                         x = pad,
                         y = window.h - height_no_completions + pad,
                         h = mode_line_h,
                         w = window.w - 2 * pad,
                       },
                       {
                         type = "Frame",
                         name = "message",
                         font = "feedback_main",
                         x = pad,
                         y = window.h - height_no_completions + mode_line_h + 1 * pad,
                         h = char_h + 2 * pad,
                         w = window.w - 2 * pad,
                         pad = pad
                       }
  ))

  return layer
end

function getWindowSettings()
  local exists,prev_window_settings = reaper_io.get("feedback", "window_settings")
  if exists then
    return prev_window_settings
  end

  return {
    w = scale(800),
    x = scale(500),
    y = scale(500),
    dock = 0,
  }
end

function createWindow(props)
  local window_settings = getWindowSettings()
  local window = GUI.createWindow({
      name = "Reaper Keys Feedback",
      w = window_settings.w,
      x = window_settings.x,
      y = window_settings.y,
      dock = window_settings.dock,
      corner = "TL"
  })

  local layer = createElements(props.elements, window)
  window:addLayers(layer)

  local completions_element = GUI.findElementByName("completions")
  setupCompletionsElement(completions_element, props)

  return window
end

function setupCompletionsElement(completions_element, props)
  local column_pad = scale(20)
  local row_pad = 0
  completions_element.drawText = function(self)
    if self.text and type(self.text) == 'table' then
      Font.set("feedback_main")
      local char_w, char_h = gfx.measurestr("i")
      gfx.x, gfx.y = self.pad + 1, self.pad + 1

      local completions = self.text
      local current_row = 0
      local num_rows = config.feedback.num_completion_rows

      local column_width = 0
      local column_key_width = 0
      local column_x = gfx.x
      for i,completion in pairs(completions) do
        gfx.x = column_x
        gfx.y = current_row * (char_h + row_pad)

        Font.set("feedback_key")
        Color.set(props.colors.key)
        gfx.drawstr(completion.key_sequence)

        local key_width = gfx.x - column_x
        if key_width > column_key_width then
          column_key_width = key_width
        end

        Font.set("feedback_arrow")
        Color.set(props.colors.arrow)

        gfx.drawstr(" -> ")

        Font.set("feedback_main")
        local action_type_color = config.action_type_colors[completion.action_type]
        Color.set(action_type_color)
        if completion.folder == true then
          Font.set("feedback_folder")
          Color.set(props.colors.folder)
        end

        gfx.drawstr(completion.value)

        current_row = current_row + 1

        local row_width = gfx.x - column_x
        if row_width > column_width then
          column_width = row_width
        end

        if current_row == num_rows then
          column_x = column_x + column_width + column_pad
          column_width = 0
          key_width = 0
          current_row = 0
        end
      end
    end
  end
end

function View:new()
  local view = {}
  setmetatable(view, self)
  self.__index = self
  self.props = config.feedback
  gui_utils.addFonts(self.props.fonts)
  self.window = createWindow(self.props)
  self.elements = {
    completions = GUI.findElementByName("completions"),
    message = GUI.findElementByName("message"),
    modeline = GUI.findElementByName("modeline"),
  }

  return view
end

function createMeasurements(props)
  Font.set("feedback_main")
  local _, char_h = gfx.measurestr("i")
  local pad = scale(props.elements.padding)
  local message_h = char_h + 2 * pad
  local height_no_completions = scale(props.elements.mode_line_h) + message_h + 2 * pad
  return {
    char_h = char_h,
    pad = pad,
    message_h = message_h,
    height_no_completions = height_no_completions
  }
end

function View:resizeWindowToFitCompletions(completions)
  local measurements = createMeasurements(self.props)
  local completions_h = #completions * measurements.char_h + 2 * measurements.pad
  local new_height = completions_h + measurements.height_no_completions
  -- FIXME shift elements down
  self.window:reopen({h = new_height})
end

function View:update(model)
  if model.completions and #model.completions > 0 then
    self:resizeWindowToFitCompletions(model.completions)
  end

  for element_name,element in pairs(self.elements) do
    element:val(model[element_name])
  end
end

function View:handleResize()
    self.window.state.resized = false
    -- TODO
end

function View:open()
  local update_number = 0
  reaper_io.set("feedback", "open", {true}, false)

  local function main()
    if self.window.state.resized then
      self:handleResize()
    end

    -- FIXME,, dont read every loop
    local model = model_interface.read()
    if model.update_number ~= update_number then
      self:update(model)
      update_number = model.update_number
    end
  end

  local function exit()
    reaper_io.set("feedback", "open", {false}, false)
    local window_settings = gui_utils.getWindowSettings()
    reaper_io.set("feedback", "window_settings", window_settings, true)
  end
  reaper.atexit(exit)

  self.window:open()
  GUI.func = main
  GUI.funcTime = 0
  GUI.Main()
end

return View
