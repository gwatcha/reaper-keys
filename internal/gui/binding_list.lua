local definitions = require('utils.definitions')
local state_interface = require('state_machine.state_interface')
local config = require('definitions.gui_config').binding_list
local runner = require('command.runner')
local state_machine_constants = require('state_machine.constants')
local fuzzy_match = require('fuzzy_match').fuzzy_match
local log = require('utils.log')
local format = require('utils.format')
local action_sequences = require('command.action_sequences')

local scythe = require('scythe')
local Const = require("public.const")
local Font = require("public.font")
local GUI = require('gui.core')
local Color = require('public.color')
local Text = require('public.text')

local gui_utils = require('gui.utils')
local scale = gui_utils.scale

local MAX_W = 2048
local MAX_H = 1610

BindingList = {}

function setupListBox(list_box)
  list_box.drawText = function(self)
    gfx.x, gfx.y = self.x + self.pad, self.y + self.pad
    local r = gfx.x + self.w - 2*self.pad
    local b = gfx.y + self.h - 2*self.pad

    Font.set(config.main_font)
    local _, main_font_h = gfx.measurestr("_")

    local outputText = {}
    for i = self.windowY, math.min(self:windowBottom() - 1, #self.list) do
      local current_row = self.list[i]

      local action_name = current_row.action_name

      local index = 1
      for char in action_name:gmatch"." do
        Color.set(config.colors.action_name)
        for _,matched_index in ipairs(current_row.matched_indices) do
          if index == matched_index then
            Color.set(config.colors.matched_key)
            break
          end
        end

        gfx.drawstr(self:formatOutput(char))

        index = index + 1
      end

      local binding = current_row.action_binding
      if binding then
        Color.set(config.colors.action_name)
        gfx.drawstr(" (")
        Color.set(config.colors.bindings[current_row.context])
        gfx.drawstr(self:formatOutput(binding))
        Color.set(config.colors.action_name)
        gfx.drawstr(")  ")
      end

      Font.set(config.aux_font)
      local action_type_color = config.colors.action_type[current_row.action_type]
      if action_type_color then
        Color.set(action_type_color)
      end

      local str_w,str_h = gfx.measurestr(current_row.action_type)
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

      Font.set(config.main_font)
      gfx.y = gfx.y + main_font_h
    end

    Font.set(config.aux_font)
    Color.set(config.colors.count)
    gfx.y = gfx.y + self.pad / 2
    gfx.drawstr(#self.list)
    gfx.drawstr(" bindings")
  end
end

function getActionTypes()
  local action_types = {}
  local seen_types = {}
  local bindings = definitions.getAllBindings()
  for context,context_bindings in pairs(bindings) do
    for action_type,action_type_bindings in pairs(context_bindings) do
      if not seen_types[action_type] then
        table.insert(action_types, action_type)
        seen_types[action_type] = true
      end
    end
  end

  table.sort(action_types)
  return action_types
end

function makeBindingListWindow()
  local prev_binding_list = state_interface.getField("binding_list_window")
  if not prev_binding_list then
    prev_binding_list = state_machine_constants.reset_state.binding_list
  end

  local window = GUI.createWindow({
      name = "Reaper Keys Action List",
      w = (prev_binding_list.w < MAX_W) and prev_binding_list.w or MAX_W,
      h = (prev_binding_list.h < MAX_H) and prev_binding_list.h or MAX_H,
      dock = 0,
      anchor = config.anchor,
      corner = config.corner,
  })

  local layer = GUI.createLayer({name = "MainLayer"})

  local main_font_preset_name = "binding_list_main"
  gui_utils.addFont(config.main_font, main_font_preset_name)
  local aux_font_preset_name = "binding_list_aux"
  gui_utils.addFont(config.aux_font, aux_font_preset_name)

  Font.set(main_font_preset_name)
  local _, char_h = gfx.measurestr("i")
  Font.set(aux_font_preset_name)
  local _, aux_char_h = gfx.measurestr("i")

  local top_pad = scale(5)
  local bottom_pad = scale(5)
  local side_pad = scale(20)
  local top_bar_element_h = char_h + scale(5)
  local top_bar_h = top_pad + top_bar_element_h + bottom_pad


  local captions = {"Valid In State", "Context", "Type"}
  if gfx.measurestr("ContextType") > window.w / 10 then
    captions[2] = ""
    captions[3] = ""
    if gfx.measurestr("Valid In State") > 6 * window.w / 32 then
      captions[1] = ""
    end
  end

  local padding_x = scale(4)
  local check_box_w = scale(20)
  local menu_box_w = window.w / 8
  local filters_x = window.w / 3 + padding_x * 2

  layer:addElements( GUI.createElements(
                       {
                         name = "query",
                         type = "Textbox",
                         x = side_pad,
                         y = top_pad,
                         displayFocus = false,
                         caption = "",
                         captionPosition = "top",
                         h = top_bar_element_h,
                         w = window.w / 3 - window.w / 32,
                         focus = true,
                         caption = "",
                         textFont = main_font_preset_name,
                         captionFont = aux_font_preset_name,
                       },
                       {
                         name = "state_label",
                         type = "Label",
                         x = filters_x,
                         font = aux_font_preset_name,
                         y = top_pad + aux_char_h / 2 + scale(2),
                         caption = captions[1]
                       },
                       {
                         name = "state_filter_active",
                         type =  "Checklist",
                         x = filters_x + padding_x + gfx.measurestr(captions[1]),
                         y = top_pad,
                         h = top_bar_element_h,
                         selectedOptions = { prev_binding_list.state_filter_active },
                         w = window.w / 32,
                         frame = false,
                         optionSize = top_bar_element_h,
                         caption = "",
                         options = {""},
                         pad = 0,
                       },
                       {
                         name = "context_filter",
                         type =  "Menubox",
                         x = window.w - 2 * menu_box_w - 2 * check_box_w - 7 * padding_x - gfx.measurestr(captions[3]) - side_pad,
                         y = top_pad,
                         h = top_bar_element_h,
                         w = window.w / 8,
                         frame = false,
                         optionSize = scale(20),
                         retval = prev_binding_list.context_filter,
                         textFont = aux_font_preset_name,
                         captionFont = aux_font_preset_name,
                         caption = captions[2],
                         auxFont = aux_font_preset_name,
                         options = {"global", "main", "midi"},
                         pad = scale(5),
                       },
                       {
                         name = "context_filter_active",
                         type =  "Checklist",
                         x = window.w - menu_box_w - 2 * check_box_w - 6 * padding_x - gfx.measurestr(captions[3]) - side_pad,
                         y = top_pad,
                         h = top_bar_element_h,
                         w = window.w / 32,
                         selectedOptions = { prev_binding_list.context_filter_active },
                         frame = false,
                         optionSize = top_bar_element_h,
                         caption = "",
                         options = {""},
                         pad = 0,
                       },
                       {
                         name = "type_filter",
                         type =  "Menubox",
                         x = window.w - menu_box_w - check_box_w - padding_x - side_pad,
                         y = top_pad,
                         h = top_bar_element_h,
                         w = menu_box_w,
                         retval = prev_binding_list.type_filter,
                         frame = false,
                         optionSize = scale(20),
                         textFont = aux_font_preset_name,
                         captionFont = aux_font_preset_name,
                         caption = captions[3],
                         options = getActionTypes(),
                         pad = scale(5),
                       },
                       {
                         name = "type_filter_active",
                         type =  "Checklist",
                         x = window.w - side_pad - check_box_w,
                         y = top_pad,
                         h = top_bar_element_h,
                         w = window.w / 32,
                         selectedOptions = { prev_binding_list.type_filter_active },
                         frame = false,
                         optionSize = top_bar_element_h,
                         caption = "",
                         options = {""},
                         pad = 0,
                       },
                       {
                         type = "Listbox",
                         name = "list_box",
                         x = 0,
                         y = top_bar_h,
                         textFont = main_font_preset_name,
                         h = window.h - top_bar_h,
                         w = window.w,
                         pad = scale(20),
                       }
  ))

  window:addLayers(layer)
  return window
end

function isRowValidInCurrentState(row, state_action_sequences, state_entries, context)
  local types_seen = {}
  local valid = false
  for _,action_sequence in ipairs(state_action_sequences) do
    local data = {}
    local first_action_type = action_sequence[1]
    if not types_seen[first_action_type] then
      local entries_for_type = state_entries[first_action_type]
      local bindings_for_type = definitions.getBindings(entries_for_type)

      if bindings_for_type[row.action_name] and row.action_type == first_action_type and (row.context == 'global' or row.context == context)  then
        valid = true
        break
      end
    end
  end

  return valid
end

function makeBindingListData(state)
  local data = {}
  local state_action_sequences = action_sequences.getPossibleActionSequences(state['context'], state['mode'])
  local state_entries = definitions.getPossibleEntries(state['context'])
  local context = state['context']

  local bindings = definitions.getAllBindings()
  for context,context_bindings in pairs(bindings) do
    for action_type,action_type_bindings in pairs(context_bindings) do
      for action_name,action_binding in pairs(action_type_bindings) do
        local row = {
          match_score = 0,
          matched_indices = {},
          context = context,
          action_name = action_name,
          action_binding = action_binding,
          action_type = action_type,
        }

        row.is_valid_in_state = isRowValidInCurrentState(row, state_action_sequences, state_entries, context)
        table.insert(data, row)
      end
    end
  end

  return data
end

function BindingList:saveState()
  local binding_list_state = {
    w = (self.window.state.currentW < MAX_W) and self.window.state.currentW or MAX_W,
    h = (self.window.state.currentH < MAX_H) and self.window.state.currentH or MAX_H,
    state_filter_active = self.values.state_filter_active,
    context_filter_active = self.values.context_filter_active,
    context_filter = self.values.context_filter,
    type_filter_active = self.values.type_filter_active,
    type_filter = self.values.type_filter
  }
  state_interface.setField("binding_list_window", binding_list_state)
end

function BindingList:new(state)
  local binding_list = {}
  setmetatable(binding_list, self)
  self.__index = self
  self.list = makeBindingListData(state)

  self.window = makeBindingListWindow()

  self.values = getElementValues()

  local list_box = GUI.findElementByName("list_box")
  setupListBox(list_box)
  self:updateDisplayedList()
  list_box:val(1)

  self.values = getElementValues()

  local query = GUI.findElementByName("query")
  query.processKey[Const.chars.DOWN] = function()
    if self.values.list_box < #list_box.list then
      self.values.list_box = self.values.list_box + 1
    end
    list_box:val(self.values.list_box)
  end
  query.processKey[Const.chars.UP] = function()
    if self.values.list_box > 1 then
      self.values.list_box = self.values.list_box - 1
    end
    list_box:val(self.values.list_box)
  end
  query.processKey[Const.chars.RETURN] = function()
    local selected_row = list_box.list[self.values.list_box]
    if selected_row then
      runner.runAction(selected_row.action_name)
    end
    self.window:close()
  end

  return binding_list
end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function BindingList:rowIsFiltered(row)
  if self.values.query ~= "" and row.match_score < -3 then
    return true
  end

  if self.values.state_filter_active and not row.is_valid_in_state then
    return true
  end

  if self.values.context_filter_active then
    local _,context = GUI.findElementByName("context_filter"):val()
    if row.context ~= context then
      return true
    end
  end

  if self.values.type_filter_active and row.action_type ~= self.values.type_filter then
    local _,action_type = GUI.findElementByName("type_filter"):val()
    if row.action_type ~= action_type then
      return true
    end
  end

  return false
end

function BindingList:updateDisplayedList()
  local displayed_list = {}
  for _,row in ipairs(self.list) do
    local sequential, score, indices = fuzzy_match(self.values.query, row.action_name)
    row.match_score = score
    row.matched_indices = indices
    row.sequential_match = sequential

    if not self:rowIsFiltered(row) then
      table.insert(displayed_list, row)
    end
  end

  local sort_function = function(a, b)
    return a.match_score > b.match_score
  end
  table.sort(displayed_list, sort_function)

  GUI.findElementByName("list_box").list = displayed_list
end

function getElementValues()
  return {
    list_box = GUI.findElementByName("list_box"):val(),
    query = GUI.findElementByName("query"):val(),
    state_filter_active = GUI.findElementByName("state_filter_active"):val(nil, true),
    context_filter_active = GUI.findElementByName("context_filter_active"):val(nil, true),
    context_filter = GUI.findElementByName("context_filter"):val(),
    type_filter_active = GUI.findElementByName("type_filter_active"):val(nil, true),
    type_filter = GUI.findElementByName("type_filter"):val(),
    query = GUI.findElementByName("query"):val(),
  }
end

function BindingList:open()
  local function updateLoop()
    local element_values = getElementValues()
    local update_list = false
    for k,v in pairs(element_values) do
      if self.values[k] ~= v then
        self.values = element_values
        update_list = true
      end
    end

    if update_list then
      self:updateDisplayedList()
      self:saveState()
    end

    if self.window.state.resized then
      self.window.state.resized = false
      self:saveState()
    end
  end

  self.window:open()
  self.window.state.focusedElm = GUI.findElementByName("query")

  GUI.func = updateLoop
  GUI.funcTime = 0
  GUI.Main()
end


return BindingList
