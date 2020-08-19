-- FIXME refractor me

local config = require('definitions.gui_config')
local list_config = config.binding_list
local runner = require('command.runner')
local getActionTypes = require('command.action_sequences').getActionTypes
local createBindingListBoxElement = require('internal.gui.binding_list.binding_list_box')

local scythe = require('scythe')
local Const = require("public.const")
local Font = require("public.font")
local GUI = require('gui.core')

local gui_utils = require('gui.utils')
local scale = gui_utils.scale

View = {}

function View:updateElementDimensions()
  Font.set("binding_list_main")
  local _, char_h = gfx.measurestr("i")
  Font.set("binding_list_label")
  local _, label_char_h = gfx.measurestr("i")

  local top_pad = scale(5)
  local bottom_pad = scale(5) + label_char_h
  local side_pad = scale(20)
  local top_bar_element_h = char_h + scale(5)
  local top_bar_h = top_pad + top_bar_element_h + scale(5)
  local padding_x = scale(4)
  local check_box_w = scale(20)

  local window = self.window
  local menu_box_w = window.w / 8
  local filters_x = window.w / 3 + padding_x * 2

  local captions = {"Valid In State", "Context", "Type"}
  if gfx.measurestr("ContextType") > window.w / 10 then
    captions[2] = ""
    captions[3] = ""
    if gfx.measurestr("Valid In State") > 6 * window.w / 32 then
      captions[1] = ""
    end
  end

  local elements = self.elements
  local query = self.elements.query
  query.x = side_pad
  query.y = top_pad
  query.h = top_bar_element_h
  query.w = window.w / 3 - window.w / 32

  local state_label = elements.state_label
  state_label.x = filters_x
  state_label.y = top_pad + label_char_h / 2
  state_label.caption = captions[1]

  local state_filter_active = elements.state_filter_active
  state_filter_active.x = filters_x + padding_x + gfx.measurestr(captions[1])
  state_filter_active.y = top_pad
  state_filter_active.h = top_bar_element_h
  state_filter_active.w = window.w / 32
  state_filter_active.optionSize = top_bar_element_h

  local context_filter = elements.context_filter
  context_filter.x = window.w - 2 * menu_box_w - 2 * check_box_w - 7 * padding_x - gfx.measurestr(captions[3]) - side_pad
  context_filter.y = top_pad
  context_filter.h = top_bar_element_h
  context_filter.w = window.w / 8
  context_filter.optionSize = scale(20)
  context_filter.caption = captions[2]
  context_filter.pad = scale(5)

  local context_filter_active = elements.context_filter_active
  context_filter_active.x = window.w - menu_box_w - 2 * check_box_w - 6 * padding_x - gfx.measurestr(captions[3]) - side_pad
  context_filter_active.y = top_pad
  context_filter_active.h = top_bar_element_h
  context_filter_active.w = window.w / 32
  context_filter_active.pad = 0
  context_filter_active.optionSize = top_bar_element_h

  local action_type_filter = elements.action_type_filter
  action_type_filter.x = window.w - menu_box_w - check_box_w - padding_x - side_pad
  action_type_filter.y = top_pad
  action_type_filter.h = top_bar_element_h
  action_type_filter.w = menu_box_w
  action_type_filter.optionSize = scale(20)
  action_type_filter.caption = captions[3]
  action_type_filter.pad = scale(5)

  local action_type_filter_active = elements.action_type_filter_active
  action_type_filter_active.x = window.w - side_pad - check_box_w
  action_type_filter_active.y = top_pad
  action_type_filter_active.h = top_bar_element_h
  action_type_filter_active.w = window.w / 32
  action_type_filter_active.optionSize = top_bar_element_h
  action_type_filter_active.pad = 0

  local binding_list_box = elements.binding_list_box
  binding_list_box.x = 0
  binding_list_box.y = top_bar_h
  binding_list_box.h = window.h - top_bar_h
  binding_list_box.w = window.w
  binding_list_box.pad = scale(20)
end


function createBindingListWindow(props)
  local window_settings = {
    name = "Reaper Keys Binding List",
    corner = "TL"
  }
  for window_setting_name,window_setting_value in pairs(props.window) do
    window_settings[window_setting_name] = window_setting_value
  end
  local window = GUI.createWindow(window_settings)

  local layer = GUI.createLayer({name = "MainLayer"})

  local element_values = props.element_values

  layer:addElements( GUI.createElements(
                       {
                         name = "query",
                         type = "Textbox",
                         displayFocus = false,
                         caption = "",
                         captionPosition = "top",
                         focus = true,
                         textFont = "binding_list_main",
                         captionFont = "binding_list_label",
                       },
                       {
                         name = "state_label",
                         type = "Label",
                         font = "binding_list_label",
                       },
                       {
                         name = "state_filter_active",
                         type =  "Checklist",
                         selectedOptions = { element_values.state_filter_active },
                         frame = false,
                         caption = "",
                         options = {""},
                         pad = 0,
                       },
                       {
                         name = "context_filter",
                         type =  "Menubox",
                         frame = false,
                         retval = element_values.context_filter,
                         textFont = "binding_list_label",
                         captionFont = "binding_list_label",
                         labelFont = "binding_list_label",
                         options = {"global", "main", "midi"},
                       },
                       {
                         name = "context_filter_active",
                         type =  "Checklist",
                         selectedOptions = { element_values.context_filter_active },
                         frame = false,
                         caption = "",
                         options = {""},
                       },
                       {
                         name = "action_type_filter",
                         type =  "Menubox",
                         retval = element_values.action_type_filter,
                         frame = false,
                         textFont = "binding_list_label",
                         captionFont = "binding_list_label",
                         options = getActionTypes(),
                       },
                       {
                         name = "action_type_filter_active",
                         type =  "Checklist",
                         selectedOptions = { element_values.action_type_filter_active },
                         frame = false,
                         caption = "",
                         options = {""},
                       },
                       {
                         type = "Listbox",
                         name = "binding_list_box",
                         textFont = "binding_list_main",
                       }
  ))

  window:addLayers(layer)

  local list_box = GUI.findElementByName("binding_list_box")
  createBindingListBoxElement(list_box)

  return window
end

function View:new(props)
  local binding_list = {}
  setmetatable(binding_list, self)
  self.__index = self

  gui_utils.addFonts(list_config.fonts)

  self.window = createBindingListWindow(props)

  self.selected_i = 1
  self.action_executed = false

  local query = GUI.findElementByName("query")
  query.processKey[Const.chars.DOWN] = function()
    if self.selected_i < #self.elements.binding_list_box.list then
      self.selected_i = self.selected_i + 1
      self.elements.binding_list_box:val(self.selected_i)
      self.elements.binding_list_box:redraw()
    end
  end
  query.processKey[Const.chars.UP] = function()
    if self.selected_i > 1 then
      self.selected_i = self.selected_i - 1
      self.elements.binding_list_box:val(self.selected_i)
      self.elements.binding_list_box:redraw()
    end
  end
  query.processKey[Const.chars.RETURN] = function()
    self.action_executed = true
  end

  self.elements = {
    binding_list_box = GUI.findElementByName("binding_list_box"),
    query = GUI.findElementByName("query"),
    state_filter_active = GUI.findElementByName("state_filter_active"),
    state_label = GUI.findElementByName("state_label"),
    context_filter_active = GUI.findElementByName("context_filter_active"),
    context_filter = GUI.findElementByName("context_filter"),
    action_type_filter_active = GUI.findElementByName("action_type_filter_active"),
    action_type_filter = GUI.findElementByName("action_type_filter"),
  }

  self:updateElementDimensions()
  self:redraw()

  return binding_list
end

function View:redraw()
  if self.window.state then
    self.window.h = self.window.state.currentH
    self.window.w = self.window.state.currentW
  end

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
