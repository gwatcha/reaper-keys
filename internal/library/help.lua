local GUI = require('gui.core')

local Table = require('public.table')


------------------------------------
-------- Functions -----------------
------------------------------------


local layers

local fadeElm, fadeLayer
local function toggleLabelFade()
  if fadeElm.layer then
    -- Label:fade(len, dest, curve)
    -- len = time in seconds
    -- dest = destination layer
    -- curve = sharpness of the fade; negative values will fade in instead
    fadeElm:fade(1, nil, 6)
  else
    fadeElm:fade(1, fadeLayer, -6)
  end
end


-- Returns a list of every element in the specified z-layer and
-- a second list of each element's values
local function getValuesForLayer(layerNum)
  -- The '+ 2' here is just to translate from a tab number to its' associated
  -- layer, since there are a couple of static layers we need to skip over.
  -- More complicated scripts might have to access the Tabs element's layer list
  -- and iterate over the contents directly.

  local layer = layers[layerNum + 2]

  local values = {}
  local val

  for key, elm in pairs(layer.elements) do
    if elm.val then
      val = elm:val()
    else
      val = "n/a"
    end

    if type(val) == "table" then
      val = "{\n" .. Table.stringify(val) .. "\n}"
    end

    values[#values + 1] = key .. ": " .. tostring(val)
  end

  return layer.name .. ":\n" .. table.concat(values, "\n")
end


local function btnClick()
  local tab = GUI.findElementByName("tabs"):val()

  local msg = getValuesForLayer(tab)
  reaper.ShowMessageBox(msg, "Yay!", 0)
end


------------------------------------
-------- Window settings -----------
------------------------------------


local window = GUI.createWindow({
  name = "Vimper Customize Window",
  x = 0,
  y = 0,
  w = 432,
  h = 500,
  anchor = "mouse",
  corner = "C",
})

layers = table.pack( GUI.createLayers(
  {name = "Layer1", z = 1},
  {name = "Layer2", z = 2},
  {name = "Layer3", z = 3},
  {name = "Layer4", z = 4},
  {name = "Layer5", z = 5}
))

window:addLayers(table.unpack(layers))


------------------------------------
-------- Global elements -----------
------------------------------------


layers[1]:addElements( GUI.createElements(
  {
    name = "tabs",
    type = "Tabs",
    x = 0,
    y = 0,
    w = 64,
    h = 20,
    tabs = {
      {
        label = "Define Key",
        layers = {layers[3]}
      },
      {
        label = "Options",
        layers = {layers[4]}
      },
    },
    pad = 16
  }
))

layers[2]:addElements( GUI.createElement(
  {
    name = "frmTabBackground",
    type = "Frame",
    x = 0,
    y = 0,
    w = 448,
    h = 20,
  }
))


------------------------------------
-------- Tab 1 Elements ------------
------------------------------------

layers[3]:addElements( GUI.createElements(
                         {
                           name = "textbox",
                           type = "Textbox",
                           x = 96,
                           y = 28,
                           w = 96,
                           h = 20,
                           caption = "Key Sequence:",
                         },
                         {
                           name = "btnGo",
                           type = "Button",
                           x = 250,
                           y = 28,
                           w = 96,
                           h = 20,
                           caption = "Go!",
                           func = btnClick
                         },
                         {
                           name = "frmDivider",
                           type = "Frame",
                           x = 0,
                           y = 56,
                           w = window.w,
                           h = 1,
                         },
                         {
                           name = "chkNames",
                           type = "Checklist",
                           x = 32,
                           y = 96,
                           w = 160,
                           h = 160,
                           caption = "Checklist:",
                           options = {"Alice","Bob","Charlie","Denise","Edward","Francine"},
                           dir = "v"
                         },
                         {
                           name = "optFoods",
                           type = "Radio",
                           x = 200,
                           y = 96,
                           w = 160,
                           h = 160,
                           caption = "Options:",
                           options = {"Apples","Bananas","_","Donuts","Eggplant"},
                           dir = "v",
                           swap = true,
                           tooltip = "Well hey there!"
                         },
                         {
                           name = "chkNames2",
                           type = "Checklist",
                           x = 32,
                           y = 280,
                           w = 384,
                           h = 64,
                           caption = "Whoa, another Checklist",
                           options = {"A","B","C","_","E","F","G","_","I","J","K"},
                           horizontal = true,
                           swap = true
                         },
                         {
                           name = "optNotes",
                           type = "Radio",
                           x = 32,
                           y = 364,
                           w = 384,
                           h = 64,
                           caption = "Horizontal options",
                           options = {"A","A#","B","C","C#","D","D#","E","F","F#","G","G#"},
                           horizontal = true,
                         }
                     ))


------------------------------------
-------- Tab 2 Elements ------------
------------------------------------

layers[4]:addElements( GUI.createElements(
                         {
                           name = "chkNames",
                           type = "Checklist",
                           x = 32,
                           y = 96,
                           w = 160,
                           h = 160,
                           caption = "Checklist:",
                           options = {"Alice","Bob","Charlie","Denise","Edward","Francine"},
                           dir = "v"
                         },
                         {
                           name = "optFoods",
                           type = "Radio",
                           x = 200,
                           y = 96,
                           w = 160,
                           h = 160,
                           caption = "Options:",
                           options = {"Apples","Bananas","_","Donuts","Eggplant"},
                           dir = "v",
                           swap = true,
                           tooltip = "Well hey there!"
                         },
                         {
                           name = "chkNames2",
                           type = "Checklist",
                           x = 32,
                           y = 280,
                           w = 384,
                           h = 64,
                           caption = "Whoa, another Checklist",
                           options = {"A","B","C","_","E","F","G","_","I","J","K"},
                           horizontal = true,
                           swap = true
                         },
                         {
                           name = "optNotes",
                           type = "Radio",
                           x = 32,
                           y = 364,
                           w = 384,
                           h = 64,
                           caption = "Horizontal options",
                           options = {"A","A#","B","C","C#","D","D#","E","F","F#","G","G#"},
                           horizontal = true,
                         }
                     ))

------------------------------------
-------- Main functions ------------
------------------------------------


-- This will be run on every update loop of the GUI script; anything you would put
-- inside a reaper.defer() loop should go here. (The function name doesn't matter)
local function Main()

  -- Prevent the user from resizing the window
  if window.state.resized then
    -- If the window's size has been changed, reopen it
    -- at the current position with the size we specified
    window:reopen({w = window.w, h = window.h})
  end

end

function start()
  -- Open the script window and initialize a few things
  window:open()

  -- Tell the GUI library to run Main on each update loop
  -- Individual elements are updated first, then GUI.func is run, then the GUI is redrawn
  GUI.func = Main

  -- How often (in seconds) to run GUI.func. 0 = every loop.
  GUI.funcTime = 0
end

-- Start the main loop
return start
