-- @module Menu

require("public.string")
local Table = require("public.table")
local T = Table.T

local Menu = {}

Menu.parse = {}

local psvPattern = "[^|]*"

--- Finds the positions of any separators (empty items or folders) in a menu string
-- @param str string A menu string, of the same form expected by `gfx.showmenu()`
-- @return array A list of separator positions
function Menu.parseString(str)
  local separators = T{}

  local i = 1
  for item in str:gmatch(psvPattern) do
    if item == ""
    or item:sub(1, 1) == ">" then
      separators:insert(i)
    end

    i = i + 1
  end

  return separators
end

--- Parses a table of menu items into a string for use with `gfx.showmenu()`
-- ```lua
-- local options = {
--   {theCaption = "a", value = 11},
--   ...
-- }
--
-- local parsed, separators = Menu.parseTable(options, "theCaption")
-- ```
-- @param menuArr array A list of menu items, with separators and folders specified
-- in the same way as expected by `gfx.showmenu()`
-- @option captionKey string For use with menu items that are objects themselves.
-- If provided, the value of `item[captionKey]` will be used as a caption in the
-- resultant menu string.
-- @return string A menu string
-- @return array A list of separator positions (i.e. empty items or folders)
function Menu.parseTable(menuArr, captionKey)
  local separators = T{}
  local menus = T{}

  for i = 1, #menuArr do
    local val
    if captionKey then
      val = menuArr[i][captionKey]
    else
      val = menuArr[i]
    end

    menus:insert(tostring(val))

    if (type(val) == "string"
      and (menus[#menus] == "" or menus[#menus]:sub(1, 1) == ">")
    ) then
      separators:insert(i)
    end
  end

  return menus:concat("|"), separators
end


--- Finds the item that was selected in a menu; `gfx.showmenu()` doesn't account
-- for folders and separators in the value it returns.
-- @param menuStr string A menu string, formatted for use with `gfx.showmenu()`
-- @param val The value returned by `gfx.showmenu()`
-- @param separators array An array of separator positions (empty items and folders),
-- as returned by `Menu.parseString` or `Menu.parseTable`
-- @return number The correct value
-- @return item The correct item in `menuStr`
function Menu.getTrueIndex(menuStr, val, separators)
  for i = 1, #separators do
    if val >= separators[i] then
      val = val + 1
    else
      break
    end
  end

  local i = 1
  local optionOut
  for option in menuStr:gmatch(psvPattern) do
    if i == val then
      optionOut = option
      break
    end

    i = i + 1
  end

  return val, optionOut
end


--- A wrapper to improve the user-friendliness of `gfx.showmenu()`, allowing
-- tables as an alternative to strings and accounting for any separators or folders
-- in the returned value. (`gfx.showmenu()` doesn't do this on its own)
--
-- Usage:
-- ```lua
-- local options = {
--   {caption = "a", value = 11},
--   {caption = ">b"},
--   {caption = "c", value = 13},
--   {caption = "<d", value = 14},
--   {caption = ""},
--   {caption = "e", value = 15},
--   {caption = "f", value = 16},
-- }
--
-- local index, value = Menu.showMenu(options, "caption", "value")
-- ```
-- For strings:
--
-- ```lua
-- local str = "1|2||3|4|5||6.12435213613"
-- local index, value = Menu.showMenu(str)
--
-- -- User clicks 1 --> 1, 1
-- -- User clicks 3 --> 4, 3
-- -- User clicks 6.12... --> 8, 6.12435213613
-- ```
-- @param menu string|array A list of menu items, formatted either as a string
-- for `gfx.showmenu()` or an array of items.
-- @option captionKey string If an array passed for `menu` contains objects rather
-- than simple strings, this parameter should be used to specify which key in the
-- object to use as a caption for the menu item.
-- @option valKey string If an array passed for `menu` contains objects rather
-- than simple strings, this parameter should be used to specify which key in the
-- object to use as the value returned by `Menu.showMenu`.
-- @return number The value, or array index, of the selected item; as with
-- `gfx.showmenu()`, will return `0` if no item is selected
-- @return any The caption, or array item, that was selected. If no item was
-- selected, will return `nil`
function Menu.showMenu(menu, captionKey, valKey)
  if type(menu) == "string" then
    local separators = Menu.parseString(menu)
    local rawIdx = gfx.showmenu(menu)
    local trueIdx = Menu.getTrueIndex(menu, rawIdx, separators)

    local options = menu:split("|")
    return trueIdx, options[trueIdx]
  else
    local parsed, separators = Menu.parseTable(menu, captionKey)

    local rawIdx = gfx.showmenu(parsed)
    local trueIdx = Menu.getTrueIndex(parsed, rawIdx, separators)

    if valKey then
      return trueIdx, menu[trueIdx][valKey]
    else
      return trueIdx, menu[trueIdx]
    end
  end
end

return Menu
