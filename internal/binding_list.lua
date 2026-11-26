local Const = require "public.const"
local Font = require "public.font"
local GUI = require "gui.core"
local Color = require "public.color"

local action_sequence = require "action_sequence"
local build = require 'build'
local definition_tables = require "definitions.bindings"
local fuzzy_match = require "fuzzy".fuzzy_match
local gui = require "definitions.config".gui
local gui_utils = require "gui.utils"
local list_config = gui.binding_list
local reaper_state = require "reaper_state"
local scale = gui_utils.scale
local utils = require 'utils'

---@class Elements
---@field query string
---@field state_filter_active boolean
---@field context_filter_active boolean
---@field action_type_filter_active boolean
---@field context Context
---@field action_type ActionType

---@class Row
---@field match_score number
---@field is_valid_in_state boolean
---@field context Context
---@field action_type ActionType

View = {}

local function drawText(self)
    gfx.x, gfx.y = self.x + self.pad, self.y + self.pad

    Font.set("binding_list_main")
    local _, main_font_h = gfx.measurestr("_")

    for i = self.windowY, math.min(self:windowBottom() - 1, #self.list) do
        local current_row = self.list[i]

        local action_name = current_row.action_name

        local index = 1
        for char in action_name:gmatch "." do
            Color.set(list_config.colors.action_name)
            for _, matched_index in ipairs(current_row.matched_indices) do
                if index == matched_index then
                    Color.set(list_config.colors.matched_key)
                    break
                end
            end

            gfx.drawstr(self:formatOutput(char))

            index = index + 1
        end

        local binding = current_row.action_binding
        if binding then
            Color.set(list_config.colors.action_name)
            gfx.drawstr(" (")
            Color.set(list_config.colors.bindings[current_row.context])
            gfx.drawstr(self:formatOutput(binding))
            Color.set(list_config.colors.action_name)
            gfx.drawstr(")  ")
        end

        Font.set("binding_list_label")
        local action_type_color = gui.action_type_colors[current_row.action_type]
        if action_type_color then
            Color.set(action_type_color)
        end

        local str_w, str_h = gfx.measurestr(current_row.action_type)
        local action_type_text_pos = self.w - str_w
        if action_type_text_pos > gfx.x then
            gfx.x = self.w - self.pad - str_w
        else
            gfx.x = gfx.x + 5
        end

        local old_y = gfx.y
        gfx.y = gfx.y + (main_font_h - str_h) / 2
        gfx.drawstr(current_row.action_type)
        gfx.y = old_y

        gfx.x = self.x + self.pad

        Font.set("binding_list_main")
        gfx.y = gfx.y + main_font_h
    end

    Font.set("binding_list_label")
    Color.set(list_config.colors.count)
    gfx.y = gfx.y + self.pad / 2
    gfx.drawstr(#self.list)
    gfx.drawstr(" bindings")
end

function View:updateElementDimensions()
  Font.set("binding_list_main")
  local _, char_h = gfx.measurestr("i")
  Font.set("binding_list_label")
  local _, label_char_h = gfx.measurestr("i")

  local top_pad = scale(5)
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

local function createBindingListWindow(props)
  local window_settings = {
    name = "Reaper Keys Binding List",
    corner = "TL",
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
                         retval = element_values.context_i,
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
                         retval = element_values.action_type_i,
                         frame = false,
                         textFont = "binding_list_label",
                         captionFont = "binding_list_label",
                         options = action_sequence.action_types,
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
    list_box.list = {}
    list_box:val(1)
    list_box.drawText = drawText
    return window
end

function View:new(props)
  local binding_list = {}
  setmetatable(binding_list, self)
  self.__index = self

  gui_utils.addFonts(list_config.fonts)

  self.window = createBindingListWindow(props)

  self.selected_i = 0
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
    self.window:reopen()
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

-- this reverses the keys and values of entries
local function getBindings(entries)
  local bindings = {}
  if not entries then return bindings end

  for entry_key,entry_value in pairs(entries) do
    if utils.isFolder(entry_value) then
      local folder_table = entry_value[2]
      local folder_bindings = getBindings(folder_table)

      for action_name_from_folder,binding_from_folder in pairs(folder_bindings) do
        bindings[action_name_from_folder] = entry_key .. binding_from_folder
      end
    else
      bindings[entry_value] = entry_key
    end
  end

  return bindings
end

local function getAllBindings()
  local bindings = {}

  for context,context_definitions in pairs(definition_tables) do
    bindings[context] = {}
    for action_type,action_type_definitions in pairs(context_definitions) do
      bindings[context][action_type] = getBindings(action_type_definitions)
    end
  end

  return bindings
end

local function createBindingList(state)
  local data = {}
  local _, state_entries = build(state, false)
  local bindings = getAllBindings()

  for context,context_bindings in pairs(bindings) do
    for action_type,action_type_bindings in pairs(context_bindings) do
      local state_bindings = getBindings(state_entries[action_type])

      for action_name,action_binding in pairs(action_type_bindings) do
        local row = {
          match_score = 0,
          matched_indices = {},
          context = context,
          action_name = action_name,
          action_binding = action_binding,
          action_type = action_type,
        }

        if state_bindings[action_name] then
          row.is_valid_in_state = true
          row.action_binding = state_bindings[action_name]
        end

        table.insert(data, row)
      end
    end
  end

  return data
end

---@param row Row
---@param element_values Elements
---@return boolean
local function filtered(row, element_values)
    return (element_values.query ~= "" and row.match_score < -3) or
        (element_values.state_filter_active and not row.is_valid_in_state) or
        (element_values.context_filter_active and row.context ~= element_values.context) or
        (element_values.action_type_filter_active and row.action_type ~= element_values.action_type)
end

local function getElementValues(view)
  local context_i, context = view.elements.context_filter:val()
  local action_type_i, action_type = view.elements.action_type_filter:val()
  return {
    binding_list_box = view.elements.binding_list_box:val(),
    state_filter_active = view.elements.state_filter_active:val(nil, true),
    context_filter_active = view.elements.context_filter_active:val(nil, true),
    context = context,
    context_i = context_i,
    action_type_filter_active = view.elements.action_type_filter_active:val(nil, true),
    action_type = action_type,
    action_type_i = action_type_i,
    query = view.elements.query:val(),
  }
end

---@param element_values Elements
local function createDisplayedList(full_binding_list, element_values)
  local displayed_list = {}
  for _,row in ipairs(full_binding_list) do
    row.sequential_match, row.match_score, row.matched_indices = fuzzy_match(element_values.query, row.action_name)
    if not filtered(row, element_values) then
      table.insert(displayed_list, row)
    end
  end

  if element_values.query ~= "" then
    table.sort(displayed_list, function(a, b)
      return a.match_score > b.match_score
    end)
  else
    table.sort(displayed_list, function(a, b)
      if a.action_type == b.action_type then
        return a.action_name < b.action_name
      else
        return a.action_type > b.action_type
      end
    end)
  end

  return displayed_list
end

local function open(state)
  local saved_props = reaper_state.get("binding_list")
  if not saved_props then
    saved_props = {
      window = {},
      element_values = {}
    }
  end
  local view = View:new(saved_props)
  local element_values = {}
  local full_binding_list = createBindingList(state)
  view.elements.binding_list_box.list = full_binding_list

  local function updateLoop()
    local new_element_values = getElementValues(view)
    local update_list = false
    for element_name,new_value in pairs(new_element_values) do
      if element_values[element_name] ~= new_value then
        element_values[element_name] = new_value
        update_list = true
      end
    end

    if update_list then
      update_list = false
      view.elements.binding_list_box.list = createDisplayedList(full_binding_list, new_element_values)
    end

    if view.window.state.resized then
      view.window.state.resized = false
      view:redraw()
    end

    if view.action_executed then
      local selected_row = view.elements.binding_list_box.list[view.selected_i]
      if selected_row then
        action_sequence.run(selected_row.action_name)
      end
      view.window:close()
    end
  end

    reaper.atexit(function()
        local binding_list_state = {
          window = gui_utils.getWindowSettings(),
          element_values = element_values
        }
        reaper_state.set("binding_list", binding_list_state)
    end)

    view.window:open()
    view.window.state.focusedElm = view.elements.query

    GUI.func = updateLoop
    GUI.funcTime = 0
    GUI.Main()
end

return open
