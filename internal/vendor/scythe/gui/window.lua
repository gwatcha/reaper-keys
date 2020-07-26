--- @module Window
-- The basis of any GUI. Scripts are limited to a single window at the moment,
-- but this will hopefully change in the future.
-- @option name string The window's title
-- @option x number Horizontal distance from the left side of the overall screen
-- area, in pixels
-- @option y number Vertical distance from the top of the overall screen area,
-- in pixels
-- @option w number Width, in pixels
-- @option h number Height, in pixels
-- @option dock number Dock state, as per the API documentation for `gfx.dock`.
-- @option anchor string Object that the window will be positioned relative to.
-- Can be "string" or "mouse". Defaults to "screen".
-- relative
-- @option corner string Origin point of the window itself, relative to its anchor.
-- Can be "C" (center), "T" (top), "R" (right), "B" (bottom), "L" (left), "TR"
-- , "TL", "BR", or "BL". Defaults to "C".
-- @option onResize function Script hook. See below.
-- @option onMouseMove function Script hook. See below.

local Table = require("public.table")
local T = Table.T
local Color = require("public.color")
local Font = require("public.font")
local Math = require("public.math")
local Config = require("gui.config")

local Window = T{}
Window.__index = Window
Window.__noRecursion = true

Window.defaultProps = {
  name = "Window",
  x = 0,
  y = 0,
  w = 640,
  h = 480,
  layerCount = 0,
  anchor = "screen",
  corner = "C",
  isOpen = false,
  isRunning = true,
  needsRedraw = false,
  onClose = function() Scythe.quit = true end,
}

function Window:new(props)
  local window = Table.deepCopy(props or {})
  Table.addMissingKeys(window, self.defaultProps)

  window.layers = T{}

  return setmetatable(window, self)

end

--- Opens the window.
function Window:open()
  -- TODO: Restore previous size and position

  gfx.clear = Color.toNative("background")

  if self.anchor and self.corner then
    self.x, self.y = self:getAnchoredPosition( self.x, self.y, self.w, self.h,
                                          self.anchor, self.corner)
  end

  gfx.init(self.name, self.w, self.h, self.dock or 0, self.x, self.y)

  self.currentW, self.currentH = gfx.w, gfx.h

  -- Measure the window's title bar, in case we need it
  local _, _, windowY, _, _ = gfx.dock(-1, 0, 0, 0, 0)
  local _, innerY = gfx.clienttoscreen(0, 0)
  self.titleHeight = innerY - windowY


  -- Initialize a few values
  self.state = T{
    mouse = {
      x = 0,
      y = 0,
      cap = 0,
      down = false,
      wheel = 0,
      lwheel = 0
    }
  }

  self.lastState = self.state

  self.isOpen = true

  self:sortLayers()
  for _, layer in pairs(self.layers) do
    layer:init()
  end
end

--- Closes the window and reopens it, using the given parameters.
-- @option params hash A table of window parameters. Accepts `x, y, w, h, dock`.
-- An parameters that are omitted will use the window's existing value.
function Window:reopen(params)
  -- params: x, y, w, h, dock
  local currentDock,currentX,currentY,currentW,currentH = gfx.dock(-1,0,0,0,0)

  self:clearTooltip()
  gfx.quit()
  gfx.init(
    self.name,
    (params and params.w) or currentW,
    (params and params.h) or currentH,
    (params and params.dock) or currentDock,
    (params and params.x) or currentX,
    (params and params.y) or currentY
  )

  self.currentW = gfx.w
  self.currentH = gfx.h
end

function Window:sortLayers()
  self.sortedLayers = self.layers:sortByKey("z")
end

--- Closes the window.
function Window:close()
  -- TODO: Store current size and position
  self:clearTooltip()
  self.isOpen = false
  self:onClose()
  gfx.quit()
end

--- Stops the window's update loop.
function Window:pause()
  self.isRunning = false
end

--- Resumes the window's update loop.
function Window:run()
  self.isRunning = true
end

function Window:redraw()
  if self.layerCount == 0 then return end

  local w, h = self.currentW, self.currentH

  if self.layers:any(function(l) return l.needsRedraw end)
    or self.needsRedraw then

    -- All of the layers will be drawn to their own buffer (dest = z), then
    -- composited in buffer 0. This allows buffer 0 to be blitted as a whole
    -- when none of the layers need to be redrawn.

    gfx.dest = 0
    gfx.setimgdim(0, -1, -1)
    gfx.setimgdim(0, w, h)

    Color.set("background")
    gfx.rect(0, 0, w, h, 1)

    -- Drawing from back to front
    for i = #self.sortedLayers, 1, -1 do
      local layer = self.sortedLayers[i]
        if  (layer.elementCount > 0 and not layer.hidden) then

          if layer.needsRedraw or self.needsRedraw then
            layer:redraw()
          end

          gfx.blit(layer.buffer, 1, 0, 0, 0, w, h, 0, 0, w, h, layer.x, layer.y)
        end
    end

    -- Draw developer hints if necessary
    if Scythe.developerMode then
      self:drawDev()
    else
      self:drawVersion()
    end

  end

  -- Reset them again, to be extra sure
  gfx.mode = 0
  gfx.set(0, 0, 0, 1)

  gfx.dest = -1
  gfx.blit(0, 1, 0, 0, 0, w, h, 0, 0, w, h, 0, 0)

  gfx.update()

  self.needsRedraw = false
end

--- Adds one or more layer's to the window. Layers will be automatically removed
-- from a previous window, and will be initialized if the window is already open.
function Window:addLayers(...)
  for _, layer in pairs({...}) do
    self.layers[layer.name] = layer
    layer.window = self
    self.layerCount = self.layerCount + 1

    if self.isOpen then layer:init() end
  end

  self.needsRedraw = true
  return self
end

--- Removes one or more layers from the window.
function Window:removeLayers(...)
  for _, layer in pairs({...}) do
    self.layers[layer.name] = nil
    layer.window = nil
    self.layerCount = self.layerCount - 1
  end

  self.needsRedraw = true
  return self
end

function Window:update()
  if Scythe.quit then
    self:close()
    return
  end

  if (not self.isOpen and self.isRunning) then return end
  self:sortLayers()

  self:updateInputState()
  self.elmUpdated = false

  self:handleWindowEvents()

  self:updateInputEvents()

  if self.layerCount > 0 and self.isOpen and self.isRunning then
    self:updateLayers()
  end

  if self.tooltip and not self.state.mouseOverElm then
    self:clearTooltip()
  end

end

function Window:handleWindowEvents()
  local state, last = self.state, self.lastState

  -- Window closed
  if (state.kb.char == 27 and not (  state.kb.ctrl
                              or  state.kb.shift
                              or  state.kb.alt))
    or state.kb.char == -1
    or Scythe.quit == true then

    self:close()
    return 0
  end

  -- Dev mode toggle
  if  state.kb.char == 282         and state.kb.ctrl
  and state.kb.shift and state.kb.alt then
    Scythe.developerMode = not Scythe.developerMode
    self.elmUpdated = true
    self.needsRedraw = true
  end

  if not self.lastState then return end

  -- Window resized
  if last.currentW
  and (state.currentW ~= last.currentW or state.currentH ~= last.currentH) then
    if self.onResize then
      self:onResize(state, last)
    end
    state.resized = true
  end

  -- Mouse moved
  if (state.x ~= last.x or state.y ~= last.y)
  and self.onMouseMove then
    self:onMouseMove(state, last)
  end

end

function Window:updateInputState()
  local last = self.state
  local state = T{}

  state.mouse = {
    x           = gfx.mouse_x,
    y           = gfx.mouse_y,
    cap         = gfx.mouse_cap,
    left        = gfx.mouse_cap & 1 == 1,
    right       = gfx.mouse_cap & 2 == 2,
    middle      = gfx.mouse_cap & 64 == 64,
    wheel       = gfx.mouse_wheel,
    dx          = gfx.mouse_x - last.mouse.x,
    dy          = gfx.mouse_y - last.mouse.y,

    -- Values that need to persist from one loop to the next
    lastTimeUp        = last.mouse.lastTimeUp,
    downElm         = last.mouse.downElm,
    doubleClicked   = last.doubleClicked,
    ox              = last.mouse.ox,
    oy              = last.mouse.oy,
    relativeX       = last.mouse.relativeX,
    relativeY       = last.mouse.relativeY,
    mouseOverTime   = last.mouse.mouseOverTime,
  }

  state.kb = {
    char = gfx.getchar(),
    shift = (gfx.mouse_cap & 8 == 8),
    ctrl = (gfx.mouse_cap & 4 == 4),
    alt = (gfx.mouse_cap & 16 == 16),
    meta = (gfx.mouse_cap & 32 == 32),
  }

  state.currentW = gfx.w
  state.currentH = gfx.h

  state.focusedElm = last.focusedElm

  state.setTooltip = function(str) self:setTooltip(state.mouse.x, state.mouse.y, str) end

  self.state = state
  self.lastState = last

end

--- Searches the window's layers, in `z` order, to see if any elements contain
-- a given point.
-- @param x number
-- @param y number
-- @return element|nil
function Window:findElementContaining(x, y)
  for i = 1, self.layerCount do
    local elm = self.sortedLayers[i]:findElementContaining(x, y)
    if elm then return elm end
  end
end

--- Searches the window's layers for an element matching the given name.
-- @param name string An element name
-- @return element|nil
function Window:findElementByName(name)
  for _, layer in pairs(self.layers) do
    local elm = layer:findElementByName(name)
    if elm then return elm end
  end
end

local buttons = {
  {
    btn = "",
    down = "left",
  },
  {
    btn = "Right",
    down = "right",
  },
  {
    btn = "Middle",
    down = "middle",
  },
}

function Window:updateInputEvents()
  local state = self.state
  local last = self.lastState

  local elementUpdated
  local elementToFocus
  local elementToLoseFocus

  local mouseOverElm = self:findElementContaining(state.mouse.x, state.mouse.y)
  state.mouse.overElm = mouseOverElm

  if mouseOverElm then
    if last.mouse.overElm ~= mouseOverElm then
      mouseOverElm:handleEvent("MouseEnter", state, last)
      -- TODO: Find a different way to handle this
      -- This event doesn't preclude others, so we need to reset this to avoid
      -- accidentally preventing them
      state.preventDefault = false
    else
      mouseOverElm:handleEvent("MouseOver", state, last)
      -- TODO: Find a different way to handle this
      -- This event doesn't preclude others, so we need to reset this to avoid
      -- accidentally preventing them
      state.preventDefault = false
    end

    if state.mouse.wheel ~= last.mouse.wheel then
      state.mouse.wheelInc = (state.mouse.wheel - last.mouse.wheel) / 120
      mouseOverElm:handleEvent("Wheel", state, last)

      elementUpdated = true
    end
  end

  if last.mouse.overElm and last.mouse.overElm ~= mouseOverElm then
    last.mouse.overElm:handleEvent("MouseLeave", state, last)
    -- TODO: Find a different way to handle this
    -- This event doesn't preclude others, so we need to reset this to avoid
    -- accidentally preventing them
    state.preventDefault = false
  end

  for _, button in ipairs(buttons) do
    if elementUpdated then break end

    if state.mouse[button.down] then

      if not last.mouse[button.down] then
        if mouseOverElm then
          mouseOverElm:handleEvent(button.btn.."MouseDown", state, last)

          state.mouse.ox = state.mouse.x
          state.mouse.oy = state.mouse.y

          state.mouse.elementRelativeX = state.mouse.x - mouseOverElm.x
          state.mouse.elementRelativeX = state.mouse.y - mouseOverElm.y

          if not state.preventDefault then
            elementToFocus = mouseOverElm
          end

          elementUpdated = true
        end

        state.mouse.downElm = mouseOverElm

        if last.focusedElm and mouseOverElm ~= last.focusedElm then
          -- TODO: Ensure that only one element can lose focus at a time
          elementToLoseFocus = last.focusedElm
        end

      elseif state.mouse.downElm then
        if (state.mouse.dx ~= 0 or state.mouse.dy ~= 0) then
          state.mouse.downElm:handleEvent(button.btn.."Drag", state, last)

          elementUpdated = true
        end
      end

    else
      if state.mouse.downElm and last.mouse[button.down] then
        if state.mouse.lastTimeUp
        and reaper.time_precise() - state.mouse.lastTimeUp < Config.doubleclickTime
        then
          state.mouse.downElm:handleEvent(button.btn.."DoubleClick", state, last)

          state.mouse.lastTimeUp = nil
          state.mouse.doubleClicked = true

          elementUpdated = true

        elseif not state.mouse.doubleClicked then
          state.mouse.downElm:handleEvent(button.btn.."MouseUp", state, last)

          -- TODO: Find a better way to handle this
          if Scythe.developerMode and button.down == "right" and state.kb.ctrl then
            state.mouse.downElm:showDevMenu(state)
          end

          state.mouse.downElm = nil

          state.mouse.lastTimeUp = reaper.time_precise()

          elementUpdated = true
        end
      end
    end
  end

  if state.focusedElm and state.kb.char ~= 0 then
    state.focusedElm:handleEvent("Type", state, last)
  end

  -- TODO: Ensure that only one element can lose focus at a time, since this
  -- would potentially override them
  if elementToFocus then elementToLoseFocus = last.focusedElm end
  if state.shouldLoseFocus then elementToLoseFocus = state.shouldLoseFocus end

  if elementToLoseFocus then
    elementToLoseFocus.focus = false
    elementToLoseFocus:handleEvent("LostFocus", state, last)
    elementToLoseFocus:redraw()

    state.focusedElm = nil
  end

  if elementToFocus then
    elementToFocus.focus = true
    elementToFocus:handleEvent("GotFocus", state, last)
    elementToFocus:redraw()

    state.focusedElm = elementToFocus
  end
end

function Window:updateLayers()
  for i = 1, self.layerCount do
    self.sortedLayers[i]:update(self.state, self.lastState)
  end
end


--[[
Returns x,y coordinates for a window with the specified anchor position

If no anchor is specified, it will default to the top-left corner of the screen.
    x,y   offset coordinates from the anchor position
    w,h   window dimensions
    anchor  "screen" or "mouse"
    corner  "TL"
            "T"
            "TR"
            "R"
            "BR"
            "B"
            "BL"
            "L"
            "C"
]]--
function Window:getAnchoredPosition(x, y, w, h, anchor, corner)

  local ax, ay, aw, ah = 0, 0, 0 ,0

  local _, _, screenW, screenH = reaper.my_getViewport( x, y, x + w, y + h,
                                                        x, y, x + w, y + h, 1)

  if anchor == "screen" then
    aw, ah = screenW, screenH
  elseif anchor =="mouse" then
    ax, ay = reaper.GetMousePosition()
  end

  local cx, cy = 0, 0
  if corner then
    local corners = {
        TL =  {0,               0},
        T =   {(aw - w) / 2,    0},
        TR =  {(aw - w) - 16,   0},
        R =   {(aw - w) - 16,   (ah - h) / 2},
        BR =  {(aw - w) - 16,   (ah - h) - 40},
        B =   {(aw - w) / 2,    (ah - h) - 40},
        BL =  {0,               (ah - h) - 40},
        L =   {0,               (ah - h) / 2},
        C =   {(aw - w) / 2,    (ah - h) / 2},
    }

    cx, cy = table.unpack(corners[string.upper(corner)])
  end

  x = x + ax + cx
  y = y + ay + cy

  return x, y
end


--- Displays a tooltip at the given position relative to the window.
-- @param x number
-- @param y number
-- @param str string Tooltip message
function Window:setTooltip(x, y, str)
  if not str or str == "" then return end

  reaper.TrackCtl_SetToolTip(
    str,
    self.x + x + 16,
    self.y + y + 16,
    true
  )
  self.tooltip = str

end


--- Clears the current tooltip, if any.
function Window:clearTooltip()

  reaper.TrackCtl_SetToolTip("", 0, 0, true)
  self.tooltip = nil

end


-- Display the library version number
function Window:drawVersion()

  if not Scythe.version then return 0 end

  local str = "Scythe "..Scythe.version

  Font.set("version")
  Color.set("text")

  local strWidth, strHeight = gfx.measurestr(str)

  gfx.x = gfx.w - strWidth - 6
  gfx.y = gfx.h - strHeight - 4

  gfx.drawstr(str)

end

-- Draws a grid overlay and some developer hints
-- Toggled via Ctrl+Shift+Alt+Z, or by setting Scythe.developerMode = true
function Window:drawDev()

  -- Draw a grid for placing elements
  Color.set("magenta")
  Font.set("monospace")

  for i = 0, self.w, Config.dev.gridMinor do

    local a = (i % Config.dev.gridMajor == 0)

    gfx.a = a and 1 or 0.3
    gfx.line(i, 0, i, self.h)
    gfx.line(0, i, self.w, i)

    if a then
      gfx.x, gfx.y = i + 4, 4
      gfx.drawstr(i)
      gfx.x, gfx.y = 4, i + 4
      gfx.drawstr(i)
    end

  end

  -- Mouse coordinates
  local str = "Mouse: "..
    math.modf(self.state.mouse.x)..", "..
    math.modf(self.state.mouse.y).." "

  local strWidth, strHeight = gfx.measurestr(str)
  gfx.x, gfx.y = self.w - strWidth - 2, self.h - 2*strHeight - 2

  Color.set("black")
  gfx.rect(gfx.x - 2, gfx.y - 2, strWidth + 4, 2*strHeight + 4, true)

  Color.set("white")
  gfx.drawstr(str)

  -- Mouse coordinates snapped to the grid
  local snapX = Math.nearestMultiple(self.state.mouse.x, Config.dev.gridMinor)
  local snapY = Math.nearestMultiple(self.state.mouse.y, Config.dev.gridMinor)

  gfx.x, gfx.y = self.w - strWidth - 2, self.h - strHeight - 2
  gfx.drawstr(" Snap: "..snapX..", "..snapY)

  gfx.a = 1

end

return Window
