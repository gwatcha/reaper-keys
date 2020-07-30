local actions = require('definitions.actions')
local utils = require('command.utils')
local definitions = require('utils.definitions')
local state_interface = require('state_machine.state_interface')
local state_machine_constants = require('state_machine.constants')
local config = require('definitions.gui_config')
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

function saveWindowState()
  local new_window_state = {
    w = window.state.currentW,
    h = window.state.currentH,
    dock = window.dock,
  }
  local action_list_window = state_interface.setField("action_list_window", new_window_state)
end

function addFont(font, preset_name)
  local font_name = font[1]
  local font_size = font[2]
  font_size = gui_utils.scale(font_size)
  font[2] = font_size

  if Font.exists(font_name) ~= true then
    log.warn("Font '" .. font_name .. "' does not exist! Please specify a different font in the configuration file.")
    font_name = "Liberation Mono"
    if Font.exists(font.name) ~= true then
      log.error("Default Font '" .. font_name .. "' does not exist! I dont know how to write text.")
    end
  end

  local font_preset = {}
  font_preset[preset_name] = font
  Font.addFonts(font_preset)
end


function action_list.open(state)
  local action_list_window = state_interface.getField("action_list_window")

  if not action_list_window then
    action_list_window = state_machine_constants.reset_state.action_list_window
  end

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

  local bindings = definitions.getBindings()

  local action_list_data = {}
  for context,context_bindings in pairs(bindings) do
    for action_type,action_type_bindings in pairs(context_bindings) do
      for action_name,action_binding in pairs(action_type_bindings) do
        local row = {}

        row.context = context
        row.action_type = action_type
        row.action_name = action_name
        row.binding = action_binding

        row.matched_indices = {}
        row.match_score = 1

        table.insert(action_list_data, row)
      end
    end
  end

  local function updateFinder(query)
    local action_list_data = GUI.findElementByName("finder").list

    for _,row in ipairs(action_list_data) do
      local sequential_match, score, indices = fuzzy_match(query, row.action_name)
      row.sequential_match = sequential_match
      row.match_score = score
      row.matched_indices = indices
    end

    local sort_function = function(a, b)
      return a.match_score > b.match_score
    end
    table.sort(action_list_data, sort_function)

    return true
  end

  local main_font_preset_name = "action_list_main"
  addFont(config.action_list.main_font, main_font_preset_name)
  local aux_font_preset_name = "action_list_aux"
  addFont(config.action_list.aux_font, aux_font_preset_name)

  layer:addElements( GUI.createElements(
                       {
                         name = "search",
                         type = "Textbox",
                         x = (window.w / 2) - scale(200),
                         w = scale(250),
                         pad = scale(20),
                         h = scale(30),
                         textFont = main_font_preset_name,
                         y = scale(5),
                         caption = "",
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
                         textFont = main_font_preset_name,
                         aux_font = aux_font_preset_name,
                         pad = scale(20),
                         colors = config.action_list.colors,
                         caption = "",
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
