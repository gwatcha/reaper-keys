--[[
  The bare minimum required to display a window and some elements. In Scythe v3,
  elements have defaults defined for most/all of their parameters in case you
  forget to include them or are happy with the defaults
]]--

local libPath = reaper.GetExtState("Scythe v3", "libPath")
if not libPath or libPath == "" then
    reaper.MB("Couldn't load the Scythe library. Please install 'Scythe library v3' from ReaPack, then run 'Script: Scythe_Set v3 library path.lua' in your Action List.", "Whoops!", 0)
    return
end
loadfile(libPath .. "scythe.lua")()
local GUI = require("gui.core")


------------------------------------
-------- Window settings -----------
------------------------------------


local window = GUI.createWindow({
  name = "Default Parameters",
  w = 400,
  h = 200,
})


------------------------------------
-------- GUI Elements --------------
------------------------------------


local layer = GUI.createLayer({name = "Layer1"})

layer:addElements( GUI.createElements(
  {
    name = "mnu_mode",
    type = "Menubox",
    x = 64,
  },
  {
    name = "chk_opts",
    type = "Checklist",
    x = 192,
    y = 16,
  },
  {
    name = "sldr_thresh",
    type = "Slider",
    x = 32,
    y = 96,
  },
  {
    name = "btn_go",
    type = "Button",
    x = 168,
    y = 152,
  }
))

------------------------------------
-------- Main functions ------------
------------------------------------

local state_interface = require("state_machine.state_interface")
local definitions = require("definitions")
local log = require("utils.log")

local config = definitions.read("config")["gui"]["autocomplete_help"]
local initial_state = nil
local initial_time = nil

local function loop()
  local cur_time = os.time()
  local time_user_has_been_thinking_about_which_key_to_press_next = cur_time - initial_time
  if time_user_has_been_thinking_about_which_key_to_press_next > config["delay_until_help"] then
    local current_state = state_interface.get()
    if initial_state['key_sequence'] ~= current_state['key_sequence'] then
      log.info("clos")
      window:close()
      return
    end
  end
  end


function start(state, completions)
  local curTime = os.time()
  initial_state = state

  -- Open the script window and initialize a few things
  window:addLayers(layer)
  window:open()

  -- Tell the GUI library to run Main on each update loop
  -- Individual elements are updated first, then GUI.func is run, then the GUI is redrawn
  GUI.func = Main

  -- How often (in seconds) to run GUI.func. 0 = every loop.
  GUI.funcTime = 0

  -- Start the main loop
  GUI.loop()
end

-- Start the main loop
return start
