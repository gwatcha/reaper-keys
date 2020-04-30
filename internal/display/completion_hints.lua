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
    name = "Vimper Customize Window",
    x = 0,
    dock = 1,
    y = 0,
    w = 1920,
    h = 250,
    corner = "B",
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
local log = require("utils.log")

local initial_time = nil
local window_open = false
function Main()
  local time_of_last_state_change = state_interface.get()['time']
  if time_of_last_state_change ~= initial_time then
    window:close()
  end

  local current_time = os.time()
  local user_idle_time = current_time - initial_time
  if not window_open and user_idle_time >= time_to_wait_until_completion_hints then

    log.info("hello")
    window:addLayers(layer)
    window:open()
    window_open = true

    local numeric_id  = reaper.NamedCommandLookup("_S&M_WNMAIN")
    reaper.Main_OnCommand(numeric_id, 0)
  end
end

function start(completions)
  initial_time = os.time()
  GUI.func = Main
  GUI.funcTime = 0
  GUI.Main()
end

-- Start the main loop
return start
