--- @module TextEditor
-- A multiline text editor
-- @option retval string Text content
-- @option caption string
-- @option pad number Padding between text and the textbox's edges
-- @option color string|table A color preset
-- @option captionBg string|table A color preset
-- @option bg string|table A color preset
-- @option fillColor string|table A color preset, used for the scrollbars
-- @option captionFont number A font preset
-- @option textFont number|string A font preset. **Must** be a monospaced font.
-- @option undoLimit number Undo states to keep. Defaults to `20`.
-- @option shadow boolean Draw the caption with a shadow. Defaults to `true`.
local Buffer = require("public.buffer")

local Font = require("public.font")
local Color = require("public.color")
local Math = require("public.math")
local GFX = require("public.gfx")
local Text = require("public.text")
local Const = require("public.const")
local Config = require("gui.config")
local T = require("public.table").T
require("public.string")

local TextUtils = require("gui.elements.shared.text")

local TextEditor = require("gui.element"):new()
TextEditor.__index = TextEditor

TextEditor.defaultProps = {

  type = "TextEditor",

  x = 0,
  y = 0,
  w = 256,
  h = 128,

  retval = "",

  caption = "",
  pad = 4,

  bg = "backgroundDarkest",
  captionBg = "background",
  color = "text",

  -- Scrollbar fill
  fillColor = "highlight",

  captionFont = 3,

  -- Forcing a safe monospace font to make our lives easier
  textFont = "monospace",

  windowPosition = {x = 0, y = 1},
  caret = {x = 0, y = 1},

  charH = nil,
  windowH = nil,
  windowW = nil,
  charW = nil,

  focus = false,

  undoLimit = 20,
  undoStates = {},
  redoStates = {},

  blink = 0,

  shadow = true,
}

function TextEditor:new(props)
  local txt = self:addDefaultProps(props)

  return setmetatable(txt, self)
end


function TextEditor:init()

  -- Process the initial string; split it into a table by line
  if type(self.retval) == "string" then self:val(self.retval) end

  local w, h = self.w, self.h

  self.buffer = Buffer.get()

  gfx.dest = self.buffer
  gfx.setimgdim(self.buffer, -1, -1)
  gfx.setimgdim(self.buffer, 2*w, h)

  Color.set(self.bg)
  gfx.rect(0, 0, 2*w, h, 1)

  Color.set("elementBody")
  gfx.rect(0, 0, w, h, 0)

  Color.set("highlight")
  gfx.rect(w, 0, w, h, 0)
  gfx.rect(w + 1, 1, w - 2, h - 2, 0)


end


function TextEditor:onDelete()

  Buffer.release(self.buffer)

end


function TextEditor:draw()

  -- Some values can't be set in :init() because the window isn't
  -- open yet - measurements won't work.
  if not self.windowH then self:recalculateWindow() end

  if self.caption and self.caption ~= "" then self:drawCaption() end

  -- Element body
  gfx.blit(self.buffer, 1, 0, (self.focus and self.w or 0), 0,
           self.w, self.h, self.x, self.y)

  self:drawText()

  if self.focus then
    if self.selectionStart and self.selectionEnd then self:drawSelection() end
    if self.showCaret then self:drawCaret() end
  end

  self:drawScrollbars()

end


--- Get or set the text editor's content
-- @option newval string New content
-- @return string The text editor's content
function TextEditor:val(newval)

  if newval then
    self:setEditorState(
      type(newval) == "table"
        and newval
        or self:stringToTable(newval)
    )
    self:redraw()
  else
    return table.concat(self.retval, "\n")
  end

end


function TextEditor:onUpdate()

  if self.focus then

    if self.blink == 0 then
      self.showCaret = true
    elseif self.blink == math.floor(Config.caretBlinkRate / 2) then
      self.showCaret = false
    end
    self.blink = (self.blink + 1) % Config.caretBlinkRate
    self:redraw()
  end

end


function TextEditor:lostfocus()
  self:redraw()
end




-----------------------------------
-------- Input methods ------------
-----------------------------------


function TextEditor:onMouseDown(state)
  if state.preventDefault then return end

  local scroll = self:isOverScrollbar(state.mouse.x, state.mouse.y)
  if scroll then

    self:setScrollbar(scroll, state)

  else

    self.caret = self:getCaret(state.mouse.x, state.mouse.y)

    -- Reset the caret so the visual change isn't laggy
    self.blink = 0

    -- Shift+click to select text
    if state.kb.shift and self.caret then

      self.selectionStart = {x = self.caret.x, y = self.caret.y}
      self.selectionEnd = {x = self.caret.x, y = self.caret.y}

    else

      self:clearSelection()

    end

  end

  self:redraw()

end


function TextEditor:onDoubleClick(state)
  if state.preventDefault then return end

  self:selectWord()

end


function TextEditor:onDrag(state)
  if state.preventDefault then return end

  local scroll = self:isOverScrollbar(state.mouse.ox, state.mouse.oy)
  if scroll then

    self:setScrollbar(scroll, state)

  -- Select from where the mouse is now to where it started
  else

    self.selectionStart = self:getCaret(state.mouse.ox, state.mouse.oy)
    self.selectionEnd = self:getCaret(state.mouse.x, state.mouse.y)

  end

  self:redraw()

end


function TextEditor:onType(state)
  if state.preventDefault then return end

  local char = state.kb.char

  -- Non-typeable / navigation chars
  if self.keys[char] then

    if state.kb.shift and not self.selectionStart then
      self.selectionStart = {x = self.caret.x, y = self.caret.y}
    end

    -- Flag for some keys (e.g. clipboard shortcuts) to skip
    -- the next section
    local bypass = self.keys[char](self, state)

    if state.kb.shift and char ~= Const.chars.BACKSPACE and char ~= Const.chars.TAB then

      self.selectionEnd = {x = self.caret.x, y = self.caret.y}

    elseif not bypass then

      self:clearSelection()

    end

  -- Typeable chars
  elseif Math.clamp(32, char, 254) == char then

    if self.selectionStart then self:deleteSelection() end

    self:insertChar(char)

  end

  self:setWindowToCaret()

  -- Reset the caret so the visual change isn't laggy
  self.blink = 0

end


function TextEditor:onWheel(state)
  if state.preventDefault then return end

  -- Shift -- Horizontal scroll
  if state.kb.shift then

    local len = self:getMaxLineLength()

    if len <= self.windowW then return end

    -- Scroll right/left
    local dir = state.mouse.wheelInc > 0 and 3 or -3
    self.windowPosition.x = Math.clamp(0, self.windowPosition.x + dir, len - self.windowW + 4)

  -- Vertical scroll
  else

    local len = self:getVerticalLength()

    if len <= self.windowH then return end

    -- Scroll up/down
    local dir = state.mouse.wheelInc > 0 and -3 or 3
    self.windowPosition.y = Math.clamp(1, self.windowPosition.y + dir, len - self.windowH + 1)

  end

  self:redraw()

end




------------------------------------
-------- Drawing methods -----------
------------------------------------


function TextEditor:drawCaption()

  local str = self.caption

  Font.set(self.captionFont)
  local strWidth = gfx.measurestr(str)
  gfx.x = self.x - strWidth - self.pad
  gfx.y = self.y + self.pad
  Text.drawBackground(str, self.captionBg)

  if self.shadow then
    Text.drawWithShadow(str, self.color, "shadow")
  else
    Color.set(self.color)
    gfx.drawstr(str)
  end

end


function TextEditor:drawText()

  Color.set(self.color)
  Font.set(self.textFont)

  local lines = {}
  for i = self.windowPosition.y, math.min(self:windowBottom() - 1, #self.retval) do

    local str = tostring(self.retval[i]) or ""
    lines[#lines + 1] = string.sub(str, self.windowPosition.x + 1, self:windowRight() - 1)

  end

  gfx.x, gfx.y = self.x + self.pad, self.y + self.pad
  gfx.drawstr( table.concat(lines, "\n") )

end


function TextEditor:drawCaret()

  local caretRelative = self:adjustToWindow(self.caret)

  if caretRelative.x and caretRelative.y then

    Color.set("text")

    gfx.rect(
      self.x + self.pad + (caretRelative.x * self.charW),
          self.y + self.pad + (caretRelative.y * self.charH),
          self.insertCaret and self.charW or 2,
      self.charH - 2
    )

  end

end


function TextEditor:drawSelection()

  local offsetX, offsetY = self.x + self.pad, self.y + self.pad
  local x, y, w
  local h = self.charH

  Color.set("highlight")
  gfx.a = 0.5
  gfx.mode = 1

  -- Get all the selection boxes that need to be drawn
  local coords = self:getSelection()
  local maxWidth = self.x + self.w - self.pad

  for i = 1, #coords do

    if self:selectionVisible(coords[i]) then

      -- Convert from char/row coords to actual pixels
      x = offsetX + (coords[i].x - self.windowPosition.x) * self.charW
      y = offsetY + (coords[i].y - self.windowPosition.y) * self.charH

      -- Keep the selection from spilling out past the scrollbar
      w = math.min(coords[i].w * self.charW, maxWidth - x)

      gfx.rect(x, y, w, h, true)

    end

  end

  gfx.mode = 0

  -- Later calls to Color.set should handle this, but for
  -- some reason they aren't always.
  gfx.a = 1

end


function TextEditor:drawScrollbars()

  local maxWidth, textH = self:getMaxLineLength(), self:getVerticalLength()
  local vert = textH > self.windowH
  local horz = maxWidth > self.windowW


  local x, y, w, h = self.x, self.y, self.w, self.h
  local vx, vy, vw, vh = x + w - 8 - 4, y + 4, 8, h - 16
  local hx, hy, hw, hh = x + 4, y + h - 8 - 4, w - 16, 8
  local fadeWidth = 12
  local _

  -- If we don't need scrollbars then don't draw the handles
  if not (vert or horz) then goto tracks end

  -- Draw a gradient to fade out the last ~16px of text
  Color.set("backgroundDarkest")
  for i = 0, fadeWidth do

    gfx.a = i/fadeWidth

    if vert then

      gfx.line(vx + i - fadeWidth, y + 2, vx + i - fadeWidth, y + h - 4)

      -- Fade out the top if we're not at windowPosition.y = 1
      _ = self.windowPosition.y > 1 and
        gfx.line(x + 2, y + 2 + fadeWidth - i, x + w - 4, y + 2 + fadeWidth - i)

    end

    if horz then

      gfx.line(x + 2, hy + i - fadeWidth, x + w - 4, hy + i - fadeWidth)

      -- Fade out the left if we're not at windowPosition.x = 0
      _ = self.windowPosition.x > 0 and
        gfx.line(x + 2 + fadeWidth - i, y + 2, x + 2 + fadeWidth - i, y + h - 4)

    end

  end

  _ = vert and gfx.rect(vx, y + 2, vw + 2, h - 4, true)
  _ = horz and gfx.rect(x + 2, hy, w - 4, hh + 2, true)


  ::tracks::

  -- Draw slider track
  Color.set("backgroundDark")
  GFX.roundRect(vx, vy, vw, vh, 4, 1, 1)
  GFX.roundRect(hx, hy, hw, hh, 4, 1, 1)
  Color.set("elementOutline")
  GFX.roundRect(vx, vy, vw, vh, 4, 1, 0)
  GFX.roundRect(hx, hy, hw, hh, 4, 1, 0)


  -- Draw slider fill
  Color.set(self.fillColor)

  if vert then
    local fh = (self.windowH / textH) * vh - 4
    if fh < 4 then fh = 4 end
    local fy = vy + ((self.windowPosition.y - 1) / textH) * vh + 2

    GFX.roundRect(vx + 2, fy, vw - 4, fh, 2, 1, 1)
  end

  if horz then
    local fw = (self.windowW / (maxWidth + 4)) * hw - 4
    if fw < 4 then fw = 4 end
    local fx = hx + (self.windowPosition.x / (maxWidth + 4)) * hw + 2

    GFX.roundRect(fx, hy + 2, fw, hh - 4, 2, 1, 1)
  end

end




------------------------------------
-------- Selection methods ---------
------------------------------------


function TextEditor:getSelectionCoords()

  local sx, sy = self.selectionStart.x, self.selectionStart.y
  local ex, ey = self.selectionEnd.x, self.selectionEnd.y

  -- Make sure the Start is before the End
  if sy > ey then
    sx, sy, ex, ey = ex, ey, sx, sy
  elseif sy == ey and sx > ex then
    sx, ex = ex, sx
  end

  return sx, sy, ex, ey

end


-- Figure out what portions of the text are selected
function TextEditor:getSelection()

  local sx, sy, ex, ey = self:getSelectionCoords()

  local x, w
  local selectionCoords = T{}

  -- Eliminate the easiest case - start and end are the same line
  if sy == ey then

    x = Math.clamp(self.windowPosition.x, sx, self:windowRight())
    w = Math.clamp(x, ex, self:windowRight()) - x

    selectionCoords:insert({x = x, y = sy, w = w})


  -- ...fine, we'll do it the hard way
  else

    -- Start
    x = Math.clamp(self.windowPosition.x, sx, self:windowRight())
    w = math.min(self:windowRight(), #(self.retval[sy] or "")) - x

    selectionCoords:insert({x = x, y = sy, w = w})


    -- Any intermediate lines are clearly full
    for i = self.windowPosition.y, self:windowBottom() - 1 do

      -- Is this line within the selection?
      if i > sy and i < ey then

        w = math.min(self:windowRight(), #(self.retval[i] or "")) - self.windowPosition.x
        selectionCoords:insert({x = self.windowPosition.x, y = i, w = w})

      -- We're past the selection
      elseif i >= ey then
        break
      end

    end

    -- End
    x = self.windowPosition.x
    w = math.min(self:windowRight(), ex) - self.windowPosition.x
    selectionCoords:insert({x = x, y = ey, w = w})

  end

  return selectionCoords


end


-- Make sure at least part of this selection block is within the window
function TextEditor:selectionVisible(coords)

  return        coords.w > 0
            and coords.x + coords.w > self.windowPosition.x -- doesn't end to the left
            and coords.x < self:windowRight()               -- doesn't start to the right
            and coords.y >= self.windowPosition.y
            and coords.y < self:windowBottom()              -- and is on a visible line

end


function TextEditor:selectAll()

  self.selectionStart = {x = 0, y = 1}
  self.caret = {x = 0, y = 1}
  self.selectionEnd = {
    x = string.len(self.retval[#self.retval]),
    y = #self.retval
  }

end


function TextEditor:selectWord()

  local str = self.retval[self.caret.y] or ""

  if str == "" then return 0 end

  local sx = str:sub(1, self.caret.x):find("%s[%S]+$") or 0

  local ex =  (
    string.find( str, "%s", sx + 1) or string.len(str) + 1
  ) - (self.windowPosition.x > 0 and 2 or 1)  -- Kludge, fixes length issues

  self.selectionStart = {x = sx, y = self.caret.y}
  self.selectionEnd = {x = ex, y = self.caret.y}

end


function TextEditor:clearSelection()

  self.selectionStart, self.selectionEnd = nil, nil

end


function TextEditor:deleteSelection()

  if not (self.selectionStart and self.selectionEnd) then return 0 end

  self:storeUndoState()

  local sx, sy, ex, ey = self:getSelectionCoords()

  -- Easiest case; single line
  if sy == ey then

    self.retval[sy] =   string.sub(self.retval[sy] or "", 1, sx)..
                        string.sub(self.retval[sy] or "", ex + 1)

  else

    self.retval[sy] =   string.sub(self.retval[sy] or "", 1, sx)..
                        string.sub(self.retval[ey] or "", ex + 1)

    for _ = sy + 1, ey do
      table.remove(self.retval, sy + 1)
    end
  end

  self.caret.x, self.caret.y = sx, sy

  self:clearSelection()
  self:setWindowToCaret()

end


function TextEditor:getSelectedText()

  local sx, sy, ex, ey = self:getSelectionCoords()

  local lines = {}

  for i = 0, ey - sy do

    lines[i + 1] = self.retval[sy + i]

  end

  lines[1] = lines[1]:sub(sx + 1)
  lines[#lines] = lines[#lines]:sub(1, ex - (sy == ey and sx or 0))

  return table.concat(lines, "\n")

end


TextEditor.toClipboard = TextUtils.toClipboard
TextEditor.fromClipboard = TextUtils.fromClipboard




------------------------------------
-------- Window/Pos Helpers --------
------------------------------------


--- Updates several internal values. If `w`, `h`, `pad`, or `textFont` are changed,
-- this method should be called afterward.
function TextEditor:recalculateWindow()

  Font.set(self.textFont)
  self.charW, self.charH = gfx.measurestr("i")
  self.windowH = math.floor((self.h - 2*self.pad) / self.charH)
  self.windowW = math.floor(self.w / self.charW)

end


-- Get the right edge of the window (in chars)
function TextEditor:windowRight()
  return self.windowPosition.x + self.windowW
end


-- Get the bottom edge of the window (in rows)
function TextEditor:windowBottom()
  return self.windowPosition.y + self.windowH
end


-- Get the length of the longest line
function TextEditor:getMaxLineLength()

  local w = 0

  -- Slightly faster because we don't care about order
  for _, v in pairs(self.retval) do
    w = math.max(w, v:len())
  end

  -- Pad the window out a little
  return w + 2

end


-- Add 2 to the table length so the horizontal scrollbar isn't in the way
function TextEditor:getVerticalLength()
  return #self.retval + 2
end


-- See if a given pair of coords is in the visible window
-- If so, adjust them from absolute to window-relative
-- If not, returns nil
function TextEditor:adjustToWindow(coords)

  local x, y = coords.x, coords.y
  x = (Math.clamp(self.windowPosition.x, x, self:windowRight() - 3) == x)
            and x - self.windowPosition.x
            or nil

  y = (Math.clamp(self.windowPosition.y, y, self:windowBottom() - 1) == y)
            and y - self.windowPosition.y
            or nil

  return {x = x, y = y}

end


-- Adjust the window if the caret has been moved off-screen
function TextEditor:setWindowToCaret()

  -- Horizontal
  if self.caret.x < self.windowPosition.x + 4 then
    self.windowPosition.x = math.max(0, self.caret.x - 4)
  elseif self.caret.x > (self:windowRight() - 4) then
    self.windowPosition.x = self.caret.x + 4 - self.windowW
  end

  -- Vertical
  local bottom = self:windowBottom()
  local adj = ( (self.caret.y < self.windowPosition.y) and -1 )
          or  ( (self.caret.y >= bottom) and 1  )
          or  ( (bottom > self:getVerticalLength() and -(bottom - self:getVerticalLength() - 1) ) )

  if adj then self.windowPosition.y = Math.clamp(1, self.windowPosition.y + adj, self.caret.y) end

end


-- TextEditor - Get the closest character position to the given coords.
function TextEditor:getCaret(x, y)

  local pos = {}

  pos.x = math.floor(((x - self.x) / self.w ) * self.windowW)
          + self.windowPosition.x
  pos.y = math.floor((y - (self.y + self.pad)) /  self.charH)
          + self.windowPosition.y

  pos.y = Math.clamp(1, pos.y, #self.retval)
  pos.x = Math.clamp(0, pos.x, #(self.retval[pos.y] or ""))

  return pos

end


-- Is the mouse over either of the scrollbars?
-- Returns "h", "v", or false
function TextEditor:isOverScrollbar(x, y)

  if  self:getVerticalLength() > self.windowH
  and x >= (self.x + self.w - 12) then

    return "v"

  elseif  self:getMaxLineLength() > self.windowW
  and y >= (self.y + self.h - 12) then

    return "h"

  end

end


function TextEditor:setScrollbar(scroll, state)

  -- Vertical scroll
  if scroll == "v" then

    local len = self:getVerticalLength()
    local windowCenter = Math.round( ((state.mouse.y - self.y) / self.h) * len  )
    self.windowPosition.y = Math.round(
      Math.clamp( 1,
                  windowCenter - (self.windowH / 2),
                  len - self.windowH + 1
      )
    )

  -- Horizontal scroll
  else

    local len = self:getMaxLineLength()
    local windowCenter = Math.round( ((state.mouse.x - self.x) / self.w) * len   )
    self.windowPosition.x = Math.round(
      Math.clamp( 0,
                  windowCenter - (self.windowW / 2),
                  len + 4 - self.windowW
      )
    )

  end


end




------------------------------------
-------- Char/String Helpers -------
------------------------------------


-- Split a string by line into a table
function TextEditor:stringToTable(str)
  return self:sanitizeText(str):splitLines()
end


-- Insert a string at the caret, deleting any existing selection
-- i.e. Paste
function TextEditor:insertString(str, moveCaret)

  self:storeUndoState()

  str = self:sanitizeText(str)

  if self.selectionStart then self:deleteSelection() end

  local sx, sy = self.caret.x, self.caret.y

  local tmp = self:stringToTable(str)

  local pre = string.sub(self.retval[sy] or "", 1, sx)
  local post = string.sub(self.retval[sy] or "", sx + 1)

  if #tmp == 1 then

    self.retval[sy] = pre..tmp[1]..post
    if moveCaret then self.caret.x = self.caret.x + #tmp[1] end

  else

    self.retval[sy] = tostring(pre)..tmp[1]
    table.insert(self.retval, sy + 1, tmp[#tmp]..tostring(post))

    -- Insert our paste lines backwards so sy+1 is always correct
    for i = #tmp - 1, 2, -1 do
      table.insert(self.retval, sy + 1, tmp[i])
    end

    if moveCaret then
      self.caret = {  x = string.len(tmp[#tmp]),
              y = self.caret.y + #tmp - 1}
    end

  end

end


-- Insert typeable characters
function TextEditor:insertChar(char)

  self:storeUndoState()

  local str = self.retval[self.caret.y] or ""

  local a, b = str:sub(1, self.caret.x),
               str:sub(self.caret.x + (self.insertCaret and 2 or 1))

  self.retval[self.caret.y] = a..string.char(char)..b
  self.caret.x = self.caret.x + 1

end


-- Place the caret at the end of the current line
function TextEditor:caretToEnd()
    return string.len(self.retval[self.caret.y] or "")
end


-- Replace any characters that we're unable to reproduce properly
function TextEditor:sanitizeText(str)

  if type(str) == "string" then

    return str:gsub("\t", "    ")

  elseif type(str) == "table" then

    local lines = {}
    for i = 1, #str do

      lines[i] = str[i]:gsub("\t", "    ")

    end

    return lines

  end

end


-- Backspace by up to four " " characters, if present.
function TextEditor:backTab()

  local str = self.retval[self.caret.y]
  local pre, post = str:sub(1, self.caret.x), str:sub(self.caret.x + 1)

  local space
  pre, space = string.match(pre, "(.-)(%s*)$")

  pre = pre .. (space and string.sub(space, 1, -3) or "")

  self.caret.x = pre:len()
  self.retval[self.caret.y] = pre..post

end

TextEditor.doCtrlChar = TextUtils.doCtrlChar


-- Non-typing key commands
-- A table of functions is more efficient to access than using really
-- long if/then/else structures.
TextEditor.keys = {

  [Const.chars.LEFT] = function(self)

    if self.caret.x < 1 and self.caret.y > 1 then
      self.caret.y = self.caret.y - 1
      self.caret.x = self:caretToEnd()
    else
      self.caret.x = math.max(self.caret.x - 1, 0)
    end

  end,

  [Const.chars.RIGHT] = function(self)

    if self.caret.x == self:caretToEnd() and self.caret.y < self:getVerticalLength() then
      self.caret.y = self.caret.y + 1
      self.caret.x = 0
    else
      self.caret.x = math.min(self.caret.x + 1, self:caretToEnd() )
    end

  end,

  [Const.chars.UP] = function(self)

    if self.caret.y == 1 then
      self.caret.x = 0
    else
      self.caret.y = math.max(1, self.caret.y - 1)
      self.caret.x = math.min(self.caret.x, self:caretToEnd() )
    end

  end,

  [Const.chars.DOWN] = function(self)

    if self.caret.y == self:getVerticalLength() then
      self.caret.x = string.len(self.retval[#self.retval])
    else
      self.caret.y = math.min(self.caret.y + 1, #self.retval)
      self.caret.x = math.min(self.caret.x, self:caretToEnd() )
    end

  end,

  [Const.chars.HOME] = function(self)

    self.caret.x = 0

  end,

  [Const.chars.END] = function(self)

    self.caret.x = self:caretToEnd()

  end,

  [Const.chars.PGUP] = function(self)

    local caretOffset = self.caret and (self.caret.y - self.windowPosition.y)

    self.windowPosition.y = math.max(1, self.windowPosition.y - self.windowH)

    if caretOffset then
      self.caret.y = self.windowPosition.y + caretOffset
      self.caret.x = math.min(self.caret.x, string.len(self.retval[self.caret.y]))
    end

  end,

  [Const.chars.PGDN] = function(self)

    local caretOffset = self.caret and (self.caret.y - self.windowPosition.y)

    self.windowPosition.y = Math.clamp(
      1,
      self:getVerticalLength() - self.windowH + 1,
      self.windowPosition.y + self.windowH
    )

    if caretOffset then
      self.caret.y = self.windowPosition.y + caretOffset
      self.caret.x = math.min(self.caret.x, string.len(self.retval[self.caret.y]))
    end

  end,

  [Const.chars.BACKSPACE] = function(self)
    self:storeUndoState()

    -- Is there a selection?
    if self.selectionStart and self.selectionEnd then

      self:deleteSelection()

    -- If we have something to backspace, delete it
    elseif self.caret.x > 0 then

      local str = self.retval[self.caret.y]
      self.retval[self.caret.y] = str:sub(1, self.caret.x - 1)..
                                  str:sub(self.caret.x + 1, -1)
      self.caret.x = self.caret.x - 1

    -- Beginning of the line; backspace the contents to the prev. line
    elseif self.caret.x == 0 and self.caret.y > 1 then

      self.caret.x = #self.retval[self.caret.y - 1]
      self.retval[self.caret.y - 1] = self.retval[self.caret.y - 1] .. (self.retval[self.caret.y] or "")
      table.remove(self.retval, self.caret.y)
      self.caret.y = self.caret.y - 1

    end

  end,

  [Const.chars.TAB] = function(self, state)

    -- Disabled until Reaper supports this properly
    --self:insertChar(9)

    if state.kb.shift then
      self:backTab()
    else
      self:insertString("  ", true)
    end

  end,

  [Const.chars.INSERT] = function(self)

    self.insertCaret = not self.insertCaret

  end,

  [Const.chars.DELETE] = function(self)

    self:storeUndoState()

    -- Is there a selection?
    if self.selectionStart then

      self:deleteSelection()

    -- Deleting on the current line
    elseif self.caret.x < self:caretToEnd() then

      local str = self.retval[self.caret.y] or ""
      self.retval[self.caret.y] = str:sub(1, self.caret.x) ..
                                  str:sub(self.caret.x + 2)

    elseif self.caret.y < self:getVerticalLength() then

      self.retval[self.caret.y] = self.retval[self.caret.y] ..
                                 (self.retval[self.caret.y + 1] or "")
      table.remove(self.retval, self.caret.y + 1)

    end

  end,

  [Const.chars.RETURN] = function(self)

    self:storeUndoState()

    if self.selectionStart then self:deleteSelection() end

    local str = self.retval[self.caret.y] or ""
    self.retval[self.caret.y] = str:sub(1, self.caret.x)
    table.insert(self.retval, self.caret.y + 1, str:sub(self.caret.x + 1) )
    self.caret.y = self.caret.y + 1
    self.caret.x = 0

  end,

  -- A -- Select All
  [1] = function(self, state)
    return self:doCtrlChar(state, self.selectAll)
  end,

  -- C -- Copy
  [3] = function(self, state)
    return self:doCtrlChar(state, self.toClipboard)
  end,

  -- V -- Paste
  [22] = function(self, state)
    return self:doCtrlChar(state, self.fromClipboard)
  end,

  -- X -- Cut
  [24] = function(self, state)
    return self:doCtrlChar(state, self.toClipboard, true)
  end,

  -- Y -- Redo
  [25] = function (self, state)
    return self:doCtrlChar(state, self.redo)
  end,

  -- Z -- Undo
  [26] = function (self, state)
    return self:doCtrlChar(state, self.undo)
  end
}




------------------------------------
-------- Misc. Functions -----------
------------------------------------


TextEditor.undo = TextUtils.undo
TextEditor.redo = TextUtils.redo

TextEditor.storeUndoState = TextUtils.storeUndoState


function TextEditor:getEditorState()

  local state = { retval = {} }
  for k,v in pairs(self.retval) do
    state.retval[k] = v
  end
  state.caret = {x = self.caret.x, y = self.caret.y}

  return state

end


function TextEditor:setEditorState(retval, caret, windowPosition, selectionStart, selectionEnd)

    self.retval = retval or {""}
    self.windowPosition = windowPosition or {x = 0, y = 1}
    self.caret = caret or {x = 0, y = 1}
    self.selectionStart = selectionStart or nil
    self.selectionEnd = selectionEnd or nil

end


TextEditor.SWS_clipboard = TextUtils.SWS_clipboard

return TextEditor
