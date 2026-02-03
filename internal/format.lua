local utils = require 'utils'
local serpent = require 'serpent'
local string_util = require 'string'
local format = {}

function format.line(data)
    return serpent.line(data, { comment = false })
end

function format.block(data)
    return serpent.block(data, { comment = false })
end

local function removeUglyBrackets(key)
    local pretty_key = key
    if string_util.sub(key, 1, 1) == "<" and string_util.sub(key, #key, #key) == ">" then
        pretty_key = string_util.sub(key, 2, #key - 1)
    end

    return pretty_key
end

function format.keySequence(key_sequence)
    local rest_of_key_seq = key_sequence
    local key_sequence_string = ""
    while #rest_of_key_seq ~= 0 do
        first_key, rest_of_key_seq = utils.splitFirstKey(rest_of_key_seq)
        if tonumber(first_key) then
            key_sequence_string = key_sequence_string .. first_key
        else
            key_sequence_string = key_sequence_string .. " " .. removeUglyBrackets(first_key)
        end
    end

    return key_sequence_string .. "-"
end

---@param command Command
---@return string
function format.commandDescription(command)
    local desc = ""
    for _, command_part in pairs(command.action_keys) do
        if type(command_part) == 'table' then
            desc = desc .. '['
            for _, additional_args in pairs(command_part) do
                desc = desc .. ' ' .. additional_args
            end
            desc = desc .. ' ]'
        else
            desc = desc .. (command_part) .. " "
        end
    end
    return desc
end

return format
