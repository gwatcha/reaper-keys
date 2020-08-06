local actions = require('definitions.actions')
local utils = require('command.utils')
local definitions = require('utils.definitions')
local state_interface = require('state_machine.state_interface')
local runner = require('command.runner')
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
local FuzzyFinder = require('gui.elements.FuzzyFinder')
local Text = require('public.text')

local gui_utils = require('gui.utils')
local scale = gui_utils.scale

local action_list = {}

local window = nil

local max_w = 2048
local max_h = 1610

function saveWindowState()
  local new_window_state = {
    w = window.state.currentW,
    h = window.state.currentH,
  }
  local action_list_window = state_interface.setField("action_list_window", new_window_state)
end


function action_list.open(state)
  local action_list_window = state_interface.getField("action_list_window")

  if not action_list_window then
    action_list_window = state_machine_constants.reset_state.action_list_window
  end


  window = GUI.createWindow({
      name = "Reaper Keys Action List",
      w = (action_list_window.w < max_w) and action_list_window.w or max_w,
      h = (action_list_window.h < max_h) and action_list_window.h or max_h,
      dock = 0,
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

  local main_font_preset_name = "action_list_main"
  gui_utils.addFont(config.action_list.main_font, main_font_preset_name)
  local aux_font_preset_name = "action_list_aux"
  gui_utils.addFont(config.action_list.aux_font, aux_font_preset_name)

  layer:addElements( GUI.createElements(
                       {
                         type = "FuzzyFinder",
                         name = "finder",
                         seperator_size = config.action_list.seperator_size,
                         list = action_list_data,
                         query_font = main_font_preset_name,
                         main_font = main_font_preset_name,
                         aux_font = aux_font_preset_name,
                         colors = config.action_list.colors,
                         x = 0,
                         y = 0,
                         h = window.h,
                         w = window.w,
                         pad = scale(20),
                       }
  ))

  window:addLayers(layer)

  local finder = GUI.findElementByName("finder")

  local function main()
    if window.state.resized then
      window.state.resized = false

      if window.state.currentW < max_w then
        finder.w = window.state.currentW
        saveWindowState()
      end
      if window.state.currentH < max_h then
        finder.h = window.state.currentH
        saveWindowState()
      end

      finder:recalculateWindow()
      finder:redraw()
    end

    if finder.command_executed then
      local selected_row_i = finder.selected_row
      runner.runAction(finder.list[selected_row_i].action_name)
      window:close()
      return
    end
  end

  -- Open the script window and initialize a few things
  window:open()

  window.state.focusedElm = finder

  -- Tell the GUI library to run Main on each update loop
  -- Individual elements are updated first, then GUI.func is run, then the GUI is redrawn
  GUI.func = main

  -- How often (in seconds) to run GUI.func. 0 = every loop.
  GUI.funcTime = 0

  -- Start the main loop
  GUI.Main()
end


return action_list
