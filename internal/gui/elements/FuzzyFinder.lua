local gui_utils = require('gui.utils')
local scale = gui_utils.scale
local log = require('utils.log')
local format = require('utils.format')
local fuzzy_match = require('fuzzy_match').fuzzy_match

local Buffer = require("public.buffer")
local Const = require("public.const")
local Font = require("public.font")
local Color = require("public.color")
local Math = require("public.math")
local GFX = require("public.gfx")
local Text = require("public.text")
require("public.string")

local FuzzyFinder = require("gui.element"):new()
FuzzyFinder.__index = FuzzyFinder
FuzzyFinder.defaultProps = {
  name = "FuzzyFinder",
  type = "FuzzyFinder",
  x = 0,
  y = 0,
  w = 96,
  h = 24,
  seperator_size = 15,
  pad = 1,

  list = {},
  query = "",
  selected_row = 1,

  query_bg = "background",
  bg = "backgroundDarkest",

  query_font = "monospace",
  main_font = "monospace",
  aux_font = "monospace",
  colors = {},
  fill_color = "highlight",

  windowY = 1,
  windowW = nil,
  windowH = nil,
  windowPosition = 0,

  caret = 0,

  charW = nil,
  charH = nil,

  blink = 0,
  shadow = true,
}

function FuzzyFinder:updateList()
  for _,row in ipairs(self.list) do
    local sequential_match, score, indices = fuzzy_match(self.query, row.action_name)
    row.sequential_match = sequential_match
    row.match_score = score
    row.matched_indices = indices
  end

  local sort_function = function(a, b)
    return a.match_score > b.match_score
  end
  table.sort(self.list, sort_function)

  return true
end

function FuzzyFinder:new(props)
  local list = self:addDefaultProps(props)

  return setmetatable(list, self)
end


function FuzzyFinder:init()
  local w, h = self.w, self.h

  self.buffer = Buffer.get()

  gfx.dest = self.buffer
  gfx.setimgdim(self.buffer, -1, -1)
  gfx.setimgdim(self.buffer, w, h)

  Color.set(self.bg)
  gfx.rect(0, 0, w, h, 1)

  Color.set("elementBody")
  gfx.rect(0, 0, w, h, 0)
end

function FuzzyFinder:onDelete()
  Buffer.release(self.buffer)
end

local list_start_y = 0

function FuzzyFinder:drawText()
  Font.set(self.query_font)
  Color.set(self.colors.query)

  local str = string.sub(self.query, self.windowPosition + 1)
 gfx.x = self.x + self.pad

  gfx.y = self.y + scale(5) + self.pad
  local r = gfx.x + self.w - 8
  local b = gfx.y + gfx.texth
  gfx.drawstr(str, 0, r, b)

  list_start_y = self.y + self.pad + self.seperator_size + gfx.texth

  -- draw search contents

  gfx.x, gfx.y = self.x + self.pad, self.y + list_start_y
  local r = gfx.x + self.w - 2*self.pad
  local b = gfx.y + self.h - 2*self.pad

  Font.set(self.main_font)
  local _, main_font_h = gfx.measurestr("_")

  local outputText = {}
  for i = self.windowY, math.min(self:windowBottom() - 1, #self.list) do

    local current_row = self.list[i]

    local action_name = current_row.action_name

    local index = 1
    for char in action_name:gmatch"." do
      Color.set(self.colors.action_name)

      for _,matched_index in ipairs(current_row.matched_indices) do
        if index == matched_index then
          Color.set(self.colors.matched_key)
          break
        end
      end

      gfx.drawstr(self:formatOutput(char))

      index = index + 1
    end

    local binding = current_row.binding
    if binding then
      Color.set(self.colors.action_name)
      gfx.drawstr(" (")

      if current_row.context == 'global' then
        Color.set(self.colors.global_binding)
        gfx.drawstr(self:formatOutput(binding))
      elseif current_row.context == 'midi' then
        Color.set(self.colors.midi_binding)
        gfx.drawstr(self:formatOutput(binding))
      else
        Color.set(self.colors.main_binding)
        gfx.drawstr(self:formatOutput(binding))
      end

      Color.set(self.colors.action_name)
      gfx.drawstr(")  ")
    end

    Font.set(self.aux_font)
    local action_type_color = self.colors.action_type[current_row.action_type]
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

    -- outputText[#outputText + 1] = self:formatOutput(str)
    gfx.x = self.x + self.pad

    Font.set(self.main_font)
    gfx.y = gfx.y + main_font_h
  end
end

FuzzyFinder.processKey = {
  [Const.chars.LEFT] = function(self)
    self.caret = math.max( 0, self.caret - 1)
  end,

  [Const.chars.RIGHT] = function(self)
    self.caret = math.min( string.len(self.query), self.caret + 1 )
  end,

  [Const.chars.UP] = function(self)
    if self.selected_row == 1 then
      return
    end
    self.selected_row = self.selected_row - 1
  end,

  [Const.chars.DOWN] = function(self)
    self.selected_row = self.selected_row + 1
  end,

  [Const.chars.BACKSPACE] = function(self)
    if self.selectionStart then
      self:deleteSelection()
    else
      if self.caret <= 0 then return end
      local str = self.query
      self.query = string.sub(str, 1, self.caret - 1)..
        string.sub(str, self.caret + 1, -1)
      self.caret = math.max(0, self.caret - 1)
    end
    self:updateList()
  end,
}

function FuzzyFinder:drawSelection()

  local adjustedX = self.x + self.pad
  local adjustedY = list_start_y

  local w = self.w - 2 * self.pad
  local itemY

  Color.set("highlight")
  gfx.a = 0.5
  gfx.mode = 1

  for i = 1, #self.list do
    if i == self.selected_row and i >= self.windowY and i < self:windowBottom() then
      itemY = adjustedY + (i - self.windowY) * self.charH
      gfx.rect(adjustedX, itemY, w, self.charH, true)
    end
  end

  gfx.mode = 0
  gfx.a = 1
end


function FuzzyFinder:draw()
  -- Some values can't be set in :init() because the window isn't
  -- open yet - text measurements won't work.
  if not self.windowH then self:recalculateWindow() end

  -- Draw the caption
  if self.caption and self.caption ~= "" then self:drawCaption() end

  -- Draw the background and frame
  gfx.blit(self.buffer, 1, 0, 0, 0, self.w, self.h, self.x, self.y)

  -- Draw the text
  self:drawText()

  -- Highlight any selected items
  self:drawSelection()

  -- Vertical scrollbar
  if #self.list > self.windowH then self:drawScrollbar() end
end


function FuzzyFinder:drawScrollbar()

  local x, y, w, h = self.x, self.y, self.w, self.h
  local sx, sy, sw, sh = x + w - 8 - 4, y + 4, 8, h - 12


  -- Draw a gradient to fade out the last ~16px of text
  Color.set("backgroundDarkest")

  local gradientOffset = sx - 15
  local gradientTop = y + 2
  local gradientBottom = y + h - 4

  for i = 0, 15 do
    gfx.a = i / 15
    gfx.line(gradientOffset + i, gradientTop, gradientOffset + i, gradientBottom)
  end

  gfx.rect(sx, y + 2, sw + 2, h - 4, true)

  -- Draw slider track
  Color.set("backgroundDark")
  GFX.roundRect(sx, sy, sw, sh, 4, 1, 1)
  Color.set("elementOutline")
  GFX.roundRect(sx, sy, sw, sh, 4, 1, 0)

  -- Draw slider fill
  local fh = (self.windowH / #self.list) * sh - 4
  if fh < 4 then fh = 4 end
  local fy = sy + ((self.windowY - 1) / #self.list) * sh + 2

  Color.set(self.fill_color)
  GFX.roundRect(sx + 2, fy, sw - 4, fh, 2, 1, 1)
end


--- Update internal values for the window size. If you change the listbox's
-- `w`, `h`, `pad`, or `textFont`, this method should be called afterward.
function FuzzyFinder:recalculateWindow()
  Font.set(self.main_font)
  self.charW, self.charH = gfx.measurestr("_")
  self.windowH = math.floor((self.h - 2*self.pad) / self.charH)
  self.windowW = math.floor(self.w / self.charW)
end

-- Get the bottom edge of the window (in rows)
function FuzzyFinder:windowBottom()
  return self.windowY + self.windowH
end

function FuzzyFinder:windowRight()
  return self.windowPosition + self.windowW
end


-- See if a given position is in the visible window
-- If so, adjust it from absolute to window-relative
-- If not, returns nil
function FuzzyFinder:adjustToWindow(x)

  return ( Math.clamp(self.windowPosition, x, self:windowRight() - 1) == x )
    and x - self.windowPosition
    or nil

end


function FuzzyFinder:setWindowToCaret()
  if self.caret < self.windowPosition + 1 then
    self.windowPosition = math.max(0, self.caret - 1)
  elseif self.caret > (self:windowRight() - 2) then
    self.windowPosition = self.caret + 2 - self.windowW
  end
end


---------------------------------
------ Input methods ------------
---------------------------------

-- Determine which item the user clicked
function FuzzyFinder:getListItem(y)

  Font.set(self.main_font)

  local item = math.floor((y - (list_start_y)) / self.charH)
    + self.windowY

  return Math.clamp(1, item, #self.list)

end


function FuzzyFinder:onMouseUp(state)
  if state.preventDefault then return end

  if not self:isOverScrollBar(state.mouse.x) then
    local item = self:getListItem(state.mouse.y)
    self.selected_row = item
  end

  self:redraw()
end


function FuzzyFinder:onMouseDown(state, _, scroll)
  if state.preventDefault then return end

  -- If over the scrollbar, or we came from :onDrag with an origin point
  -- that was over the scrollbar...
  if scroll or self:isOverScrollBar(state.mouse.x) then
    local windowCenter = Math.round(
      ((state.mouse.y - self.y) / self.h) * #self.list
    )
    self.windowY = math.floor(Math.clamp(
      1,
      windowCenter - (self.windowH / 2),
      #self.list - self.windowH + 1
    ))

    self:redraw()
  end
end

-- Is the mouse over the scrollbar (true) or the text area (false)?
function FuzzyFinder:isOverScrollBar(x)

  return (#self.list > self.windowH and x >= (self.x + self.w - 12))

end

function FuzzyFinder:onDrag(state, last)
  if state.preventDefault then return end

  if self:isOverScrollBar(last.mouse.x) then

    self:onMouseDown(state, nil, true)

  else

  -- Drag selection?
  end

  self:redraw()

end


function FuzzyFinder:onWheel(state)
  if state.preventDefault then return end

  local dir = state.mouse.wheelInc > 0 and -1 or 1

  -- Scroll up/down one line
  self.windowY = Math.clamp(
    1,
    self.windowY + dir,
    math.max(#self.list - self.windowH + 1, 1)
  )

  self:redraw()
end

function FuzzyFinder:insertChar(char)
  local a, b = string.sub(self.query, 1, self.caret),
  string.sub(self.query, self.caret + (self.insertCaret and 2 or 1))

  self.query = a..string.char(char)..b
  self:updateList()
  self.caret = self.caret + 1
end


function FuzzyFinder:onType(state)
  if state.preventDefault then return end


  local char = state.kb.char

  -- Navigation keys, Return, clipboard stuff, etc
  if self.processKey[char] then

    local shift = state.kb.shift

    if shift and not self.selectionStart then
      self.selectionStart = self.caret
    end

    -- Flag for some keys (clipboard shortcuts) to skip
    -- changing the selection range
    local bypass = self.processKey[char](self, state)

    if shift and char ~= Const.chars.BACKSPACE then

      self.selectionEnd = self.caret

    elseif not bypass then

      self.selectionStart, self.selectionEnd = nil, nil

    end

  -- Typeable chars
  elseif Math.clamp(32, char, 254) == char then
    if self.selectionStart then self:deleteSelection() end

    self:insertChar(char)
  end
  self:setWindowToCaret()

  -- Make sure no functions crash because they got a type==number
  self.query = tostring(self.query)

  -- Reset the caret so the visual change isn't laggy
  self.blink = 0

  self:redraw()
end

return FuzzyFinder


