local utils = require("command.utils")
local ser = require("serpent")
local str = require("string")

local format = {}

function format.line(data)
  return ser.line(data, {comment=false})
end

function format.block(data)
  return ser.block(data, {comment=false})
end

function formatCompletions(entries)
  local max_seq_length = 6
  for key_seq,_ in pairs(entries) do
    if type(key_seq) == 'string' and #key_seq > max_seq_length then
      max_seq_length = #key_seq
    end
  end

  local collapsed_entries = {}
  local entries_string = ""

  for key_seq, value in pairs(entries) do
    local pretty_key_seq = ""
    local pretty_value = ""
    if type(key_seq) == 'number' then
      pretty_key_seq = '(num)'
      pretty_value = '(times/select)'
    else
      pretty_key_seq = formatKeySequence(key_seq, false)
      pretty_value = value
      if utils.isFolder(value) then
        local folder_name = value[1]
        pretty_value = folder_name
      end
    end

    entry_string = str.format("%" .. max_seq_length + 1 .. "s -> %s", pretty_key_seq, pretty_value)
    entries_string = entries_string .. "\n" .. entry_string
  end

  return entries_string
end

function removeUglyBrackets(key)
  local pretty_key = key
  if str.sub(key, 1, 1) == "<" and str.sub(key, #key, #key) == ">" then
    pretty_key = str.sub(key, 2, #key - 1)
  end

  return pretty_key
end

function formatKeySequence(key_sequence, spacing)
  local rest_of_key_seq = key_sequence
  local key_sequence_string = ""
  while #rest_of_key_seq ~= 0 do
    first_key, rest_of_key_seq = utils.splitFirstKey(rest_of_key_seq)
    if tonumber(first_key) or not spacing then
      key_sequence_string = key_sequence_string .. first_key
    else
      key_sequence_string = key_sequence_string .. " " .. removeUglyBrackets(first_key)
    end
  end

  return key_sequence_string
end

function format.userInfoWithCompletions(state, future_entries)
  local key_sequence_string = formatKeySequence(state['key_sequence'])
  key_sequence_string = key_sequence_string .. "-"
  local completions = formatCompletions(future_entries)
  local mode_line_and_info_line = format.userInfo(state, key_sequence_string)

  return str.format("%s\n%s", completions, mode_line_and_info_line)
end

function format.userInfo(state, message)
  local chars_for_modes = {
    normal = "·",
    visual_timeline = "»",
    visual_track = "¬",
  }

  local right_text = ""
  if state['macro_recording'] then
    right_text = str.format("(rec %s..)", state['macro_register'])
  end

  local min_width = 30
  local width = min_width
  if #message + #right_text + 3 > min_width then
    width = #message + #right_text
  end

  info_line = str.format("%s%" .. width - #message .. "s", message, right_text)

  local pretty_mode_bar = ""
  for i=1,width do pretty_mode_bar = pretty_mode_bar .. chars_for_modes[state['mode']] end

  return str.format("%s\n%s", pretty_mode_bar, info_line)
end

return format
