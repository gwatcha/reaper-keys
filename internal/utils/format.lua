local utils = require('command.utils')
local ser = require('serpent')
local string_util = require('string')
local log = require('utils.log')

local format = {}

function pairsByKeys(t, f)
  local a = {}
  for n in pairs(t) do
    table.insert(a, n)
  end
  table.sort(a, f)
  local i = 0
  local iter = function ()
    i = i + 1
    if a[i] == nil then
      return nil
    else
      return a[i], t[a[i]]
    end
  end
  return iter
end

function sortTableAlphabetically(table_to_sort)
  local t = {}
  for title,value in pairsByKeys(table_to_sort) do
    table.insert(t, { title = title, value = value })
  end
  return t
end

function format.line(data)
  return ser.line(data, {comment=false})
end

function format.block(data)
  return ser.block(data, {comment=false})
end

function removeUglyBrackets(key)
  local pretty_key = key
  if string_util.sub(key, 1, 1) == "<" and string_util.sub(key, #key, #key) == ">" then
    pretty_key = string_util.sub(key, 2, #key - 1)
  end

  return pretty_key
end

function format.keySequence(key_sequence, spacing)
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

function format.actionSequence(action_sequence)
  local formatted = ''
  for _,action in ipairs(action_sequence) do
    formatted = formatted .. action .. ' '
  end
  return formatted
end

function format.actionSequences(action_sequences)
  local formatted = ''
  for i,action_sequence in ipairs(action_sequences) do
    formatted = formatted .. '  ' .. format.actionSequence(action_sequence) .. '\n'
  end
  return formatted
end

function format.commandDescription(command)
  local desc = ""
  for _, command_part  in pairs(command.action_keys) do
    if type(command_part) == 'table' then
      local name = command_part[1]
      desc = desc .. '['
      for _,additional_args in pairs(command_part) do
        desc = desc .. ' ' .. additional_args
      end
      desc = desc .. ']'
    else
      desc = desc .. (command_part) .. " "
    end
  end
  return desc
end

return format
