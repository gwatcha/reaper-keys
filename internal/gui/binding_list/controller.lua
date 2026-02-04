local BindingListView = require('gui.binding_list.View')
local buildCommandWithCompletions = require 'build'
local gui_utils = require('gui.utils')
local reaper_state = require('reaper_state')
local fuzzy_match = require('fuzzy').fuzzy_match
local GUI = require('gui.core')
local run = require 'action_sequence'.run
local definition_tables = require "definitions.bindings"
local utils = require 'utils'

local binding_list = {}

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
  local _, state_entries = buildCommandWithCompletions(state, false)
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

function rowIsFiltered(row, element_values)
  if (element_values.query ~= "" and row.match_score < -3) or
    (element_values.state_filter_active and not row.is_valid_in_state) or
    (element_values.context_filter_active and row.context ~= element_values.context) or
    (element_values.action_type_filter_active and row.action_type ~= element_values.action_type) then
      return true
  end

  return false
end

function getElementValues(view)
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

function createDisplayedList(full_binding_list, element_values)
  local displayed_list = {}
  for _,row in ipairs(full_binding_list) do
    row.sequential_match, row.match_score, row.matched_indices = fuzzy_match(element_values.query, row.action_name)
    if not rowIsFiltered(row, element_values) then
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

local binding_list_table_name = "binding_list"

function binding_list.open(state)
  local saved_props = reaper_state.get(binding_list_table_name)
  if not saved_props then
    saved_props = {
      window = {},
      element_values = {}
    }
  end
  local view = BindingListView:new(saved_props)
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
        run(selected_row.action_name)
      end
      view.window:close()
    end
  end

  local function saveState()
    local binding_list_state = {
      window = gui_utils.getWindowSettings(),
      element_values = element_values
    }
    reaper_state.set(binding_list_table_name, binding_list_state)
  end

  reaper.atexit(saveState)

  view.window:open()
  view.window.state.focusedElm = view.elements.query

  GUI.func = updateLoop
  GUI.funcTime = 0
  GUI.Main()
end

return binding_list
