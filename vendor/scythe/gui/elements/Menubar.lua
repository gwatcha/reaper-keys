--- @module Menubar
-- Provides a standard menubar. The `menus` property uses the form:
-- ```lua
-- menus = {
--   {
--     title = "A Menu!",
--     options = {
--       {
--         caption = "!Item 1",
--         func = item1function
--       },
--       {
--         caption = "Item 2",
--         func = item2function
--       }
--     }
--   },
--   {
--     title = "Parameters",
--     options = {
--       {
--         caption = "With parameters",
--         -- someFunction will be called with ("A", "hello!")
--         func = someFunction
--         params = {"A", "hello!"}
--       },
--     }
--   }
-- }
-- ```
-- @commonParams
-- @option menus array A list of menus, items, and callback functions. Item
-- captions use the same syntax as `gfx.showmenu` concerning separators and
-- greying out.
-- @option fullWidth boolean Automatically extend the menubar the full width of
-- the window. Defaults to `true`.
-- @option font number A font preset
-- @option textColor string|table A color preset
-- @option backgroundColor string|table A color preset
-- @option hoverColor string|table A color preset
-- @option pad number Padding between menus
-- @option shadow boolean Draw a shadow under the menubar. Defaults to `true`.
local Buffer = require("public.buffer")

local Font = require("public.font")
local Color = require("public.color")
local Menu = require("public.menu")
local Config = require("gui.config")

local Menubar = require("gui.element"):new()
Menubar.__index = Menubar
Menubar.defaultProps = {
  name = "menubar",
  type = "Menubar",

  x = 0,
  y = 0,

  font = 2,
  textColor = "text",
  backgroundColor = "elementBody",
  hoverColor = "highlight",

  w = 256,
  h = 24,

  pad = 0,

  shadow = true,
  fullWidth = true,

  menus = {},

}

function Menubar:new(props)

  local mnu = self:addDefaultProps(props)

  return setmetatable(mnu, self)

end


function Menubar:init()

  -- We can't get any text measurements until there's a window open
  if gfx.w == 0 then return end

  self.buffer = self.buffer or Buffer.get()

  -- We'll have to reset this manually since we're not running :init()
  -- until after the window is open
  local dest = gfx.dest

  gfx.dest = self.buffer
  gfx.setimgdim(self.buffer, -1, -1)


  -- Store some text measurements
  Font.set(self.font)

  self.tab = gfx.measurestr(" ") * 4

  for i = 1, #self.menus do
    self.menus[i].width = gfx.measurestr(self.menus[i].title)
  end

  self.w = self.fullWidth and (self.layer.window.currentW - self.x) or self:measureTitles(nil, true)
  self.h = self.h or gfx.texth

  -- Draw the background + shadow
  gfx.setimgdim(self.buffer, self.w, self.h * 2)

  Color.set(self.backgroundColor)

  gfx.rect(0, 0, self.w, self.h, true)

  Color.set("shadow")
  local r, g, b, a = table.unpack(Color.colors.shadow)
  gfx.set(r, g, b, 1)
  gfx.rect(0, self.h + 1, self.w, self.h, true)
  gfx.muladdrect(0, self.h + 1, self.w, self.h, 1, 1, 1, a, 0, 0, 0, 0 )

  self.didInit = true

  gfx.dest = dest

end


function Menubar:onDelete()

  Buffer.release(self.buffer)

end



function Menubar:draw()

  if not self.didInit then self:init() end

  local x, y = self.x, self.y
  local w, h = self.w, self.h

  -- Blit the menu background + shadow
  if self.shadow and Config.drawShadows then

    for i = 1, Config.shadowSize do

      gfx.blit(self.buffer, 1, 0, 0, h, w, h, x, y + i, w, h)

    end

  end

  gfx.blit(self.buffer, 1, 0, 0, 0, w, h, x, y, w, h)

  -- Draw menu titles
  self:drawTitles()

  -- Draw highlight
  if self.mouseMenu then self:drawHover() end

end


--- Get or set the menubar's menu structure. Because there are internal calculations
-- involved, the menus should only be changed via this method.
-- @option newval array A list of menus and items, as per the `menus` property
-- above.
-- @return array The current menus
function Menubar:val(newval)

  if newval and type(newval) == "table" then

    self.menus = newval
    self.w, self.h = nil, nil
    self:init()
    self:redraw()

  else

    return self.menus

  end

end


function Menubar:onResize()

  if self.fullWidth then
    self:init()
    self:redraw()
  end

end




------------------------------------
-------- Drawing methods -----------
------------------------------------


function Menubar:drawTitles()

  local currentX = self.x

  Font.set(self.font)
  Color.set(self.textColor)

  for i = 1, #self.menus do

    local str = self.menus[i].title
    local strWidth, strHeight = gfx.measurestr(str)

    gfx.x = currentX + (self.tab + self.pad) / 2
    gfx.y = self.y + (self.h - strHeight) / 2

    gfx.drawstr(str)

    currentX = currentX + strWidth + self.tab + self.pad

  end

end


function Menubar:drawHover()

    if self.menus[self.mouseMenu].title == "" then return end

    Color.set(self.hoverColor)
    gfx.mode = 1
    gfx.a = (self.mouseDown and self.mouseMenu) and 0.5 or 0.3

    gfx.rect(
      self.x + self.mouseMenuX,
      self.y,
      self.menus[self.mouseMenu].width + self.tab + self.pad,
      self.h,
      true
    )

    gfx.a = 1
    gfx.mode = 0

end




------------------------------------
-------- Input methods -------------
------------------------------------


-- Make sure to disable the highlight if the mouse leaves
function Menubar:onMouseLeave(state)
    self.mouseMenu = nil
    self.mouseMenuX = nil
    self:redraw()
end



function Menubar:onMouseUp(state)
  if state.preventDefault then return end

  if not self.mouseMenu then return end

  gfx.x, gfx.y = self.x + self:measureTitles(self.mouseMenu - 1, true), self.y + self.h

  local _, opt = Menu.showMenu(self.menus[self.mouseMenu].options, "caption")

  if opt and opt.func then
    opt.func(self, table.unpack(opt.params or {}))
  end

  self.mouseDown = false
  self:redraw()

end


function Menubar:onMouseDown(state)
  if state.preventDefault then return end

  self.mouseDown = true
  self:redraw()

end


function Menubar:onMouseOver(state)
  local x = state.mouse.x - self.x

  if self.mouseMenuX and x > self:measureTitles(nil, true) then

    self.mouseMenu = nil
    self.mouseMenuX = nil
    self:redraw()

    return
  end

  local opt = self.mouseMenu
  -- Iterate through the titles by their cumulative width until we
  -- find which one the mouse is in.
  for i = 1, #self.menus do

    if x <= self:measureTitles(i, true) then

      self.mouseMenu = i
      self.mouseMenuX = self:measureTitles(i - 1, true)

      if self.mouseMenu ~= opt and not state.preventDefault then self:redraw() end

      return
    end

  end

end


function Menubar:onDrag(state)
  self:onMouseOver(state)
end




------------------------------------
-------- Menu methods --------------
------------------------------------


-- Returns the length of the specified number of menu titles, or
-- all of them if 'num' isn't given
-- Will include tabs + padding if tabs = true
function Menubar:measureTitles(num, tabs)

  local len = 0

  for i = 1, num or #self.menus do
    len = len + self.menus[i].width
  end

  return not tabs
    and len
    or (len + (self.tab + self.pad) * (num or #self.menus))

end

return Menubar
