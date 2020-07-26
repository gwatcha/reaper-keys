local actions = require('definitions.actions')
local utils = require('command.utils')
local definitions = require('utils.definitions')
local state_interface = require('state_machine.state_interface')
local state_machine_constants = require('state_machine.constants')
local config = require('definitions.config')
local log = require('utils.log')
local format = require('utils.format')
local fuzzy_match = require('fuzzy_match').fuzzy_match

local scythe = require('scythe')
local GUI = require('gui.core')
local Textbox = require('gui.elements.Textbox')
local TextEditor = require('gui.elements.TextEditor')
local Color = require('public.color')
local Font = require('public.font')
local FuzzyFinder = require('gui.elements.FuzzyFinder')
local Text = require('public.text')

local gui_utils = require('gui.utils')
local scale = gui_utils.scale

local action_list = {}

local window = nil

-- this reverses the keys and values by 'extracting' from folders
function getActionBindings(entries)
  local action_bindings = {}
  for entry_key,entry_value in pairs(entries) do
    if utils.isFolder(entry_value) then
      local folder_table = entry_value[2]
      local folder_action_bindings = getActionBindings(folder_table)

      for action_name_from_folder,action_binding_from_folder in pairs(folder_action_bindings) do
        action_bindings[action_name_from_folder] = entry_key .. action_binding_from_folder
      end
    else
      action_bindings[entry_value] = entry_key
    end
  end

  return action_bindings
end

function saveWindowState()
  local new_window_state = {
    w = window.state.currentW,
    h = window.state.currentH,
    dock = window.dock,
  }
  local action_list_window = state_interface.setField("action_list_window", new_window_state)
end

function action_list.open(state)
  local action_list_window = state_interface.getField("action_list_window")

  if not action_list_window then
    action_list_window = state_machine_constants.reset_state.action_list_window
  end

  local font = config.action_list.font
  if Font.exists(font) ~= true then
    log.warn("Font '" .. font .. "' does not exist! Please specify a different font in the configuration file.")
    font = "Liberation Mono"
  end

  Font.addFonts({action_list_font = {font, scale(config.action_list.font_size)}})

  window = GUI.createWindow({
      name = "Reaper Keys Action List",
      w = action_list_window.w,
      h = action_list_window.h,
      dock = action_list_window.dock,
      anchor = config.action_list.anchor,
      corner = config.action_list.corner,
  })

  ------------------------------------
  -------- GUI Elements --------------
  ------------------------------------

  local layer = GUI.createLayer({name = "Layer1"})

  local query_state = state
  query_state['key_sequence'] = ""

  local global_entries

  query_state['context'] = "main"
  local main_entries = getPossibleFutureEntries(query_state)
  local main_action_bindings = getActionBindings(main_entries)

  query_state['context'] = "midi"
  local midi_entries = getPossibleFutureEntries(query_state)
  local midi_action_bindings = getActionBindings(midi_entries)

  local action_list_data = {}
  for action_name,action_value in pairs(actions) do
    local row = {}

    row.action_name = action_name
    row.matched_indices = {}
    row.match_score = 1
    row.main_key_binding = main_action_bindings[action_name]
    row.midi_key_binding = midi_action_bindings[action_name]

    table.insert(action_list_data, row)
  end

  local function updateFinder(query)
    local action_list_data = GUI.findElementByName("finder").list

    for _,row in ipairs(action_list_data) do
      local _, score, indices = fuzzy_match(query, row.action_name)
      row.match_score = score
      row.matched_indices = indices
    end

    local sort_function = function(a, b)
      return a.match_score > b.match_score
    end
    table.sort(action_list_data, sort_function)

    return true
  end

  layer:addElements( GUI.createElements(
                       {
                         name = "search",
                         type = "Textbox",
                         x = (window.w / 2) - scale(200),
                         w = scale(250),
                         pad = scale(20),
                         h = scale(30),
                         y = scale(5),
                         caption = "",
                         textFont = "action_list_font",
                         captionFont = "action_list_font",
                         validator = updateFinder,
                         validateOnType = true
                       },
                       {
                         name = "finder",
                         type = "FuzzyFinder",
                         x = window.w * 1 / 20,
                         y = scale(50),
                         h = window.h - scale(100),
                         w = window.w * 18 / 20,
                         list = action_list_data,
                         pad = scale(20),
                         match_color = {0.8, 0.22, 0, 1},
                         main_key_binding_color = {0.81, 0.64, 0.79, 1},
                         midi_key_binding_color = {0.29, 0.74, 0.69, 1},
                         global_key_binding_color = {0.49, 0.7, 0.49, 1},
                         caption = "",
                         textFont = "action_list_font",
                         captionFont = "action_list_font"
                       }
  ))

  window:addLayers(layer)

  local function main()
    if window.state.resized then
      window.state.resized = false
      -- FIXME crashes :(
      -- FuzzyFinder:recalculateWindow()
      saveWindowState()
    end
  end

  -- Open the script window and initialize a few things
  window:open()

  -- Tell the GUI library to run Main on each update loop
  -- Individual elements are updated first, then GUI.func is run, then the GUI is redrawn
  GUI.func = main

  -- How often (in seconds) to run GUI.func. 0 = every loop.
  GUI.funcTime = 0

  GUI.findElementByName("search").focus = true

  -- Start the main loop
  GUI.Main()
end

return action_list
