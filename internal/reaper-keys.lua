local info = debug.getinfo(1,'S');

local internal_root_path = info.source:match(".*reaper.keys[^\\/]*[\\/]internal[\\/]"):sub(2)
package.path = package.path .. ";" .. internal_root_path .. '?.lua'

local windows_files = internal_root_path:match("\\$")
if windows_files then
  package.path = package.path .. ";" .. internal_root_path .. "..\\definitions\\?.lua"
  package.path = package.path .. ";" .. internal_root_path .. "?\\?.lua"
  package.path = package.path .. ";" .. internal_root_path .. "vendor\\share\\lua\\5.3\\?.lua"
  package.path = package.path .. ";" .. internal_root_path .. "vendor\\share\\lua\\5.3\\?\\init.lua"
  package.path = package.path .. ";" .. internal_root_path .. "vendor\\scythe\\?.lua"
else
  package.path = package.path .. ";" .. internal_root_path .. "../definitions/?.lua"
  package.path = package.path .. ";" .. internal_root_path .. "?/?.lua"
  package.path = package.path .. ";" .. internal_root_path .. "vendor/share/lua/5.3/?.lua"
  package.path = package.path .. ";" .. internal_root_path .. "vendor/share/lua/5.3/?/init.lua"
  package.path = package.path .. ";" .. internal_root_path .. "vendor/scythe/?.lua"
end

local input = require('state_machine')
local log = require('utils.log')
local FeedbackView = require('gui.feedback.View')
local reaper_io = require('utils.reaper_io')

function doInput(key_press)
  -- reaper_io.set("feedback", "open", {false}, false)

  local exists,feedback_view_open = reaper_io.get("feedback", "open")
  if not exists or not feedback_view_open[1] then
    local feedback_view = FeedbackView:new()
    feedback_view:open()
  end

  input(key_press)
end

return doInput
