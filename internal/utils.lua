local utils = {}

---@param entry_value table
---@return boolean
function utils.isFolder(entry_value)
    return entry_value
        and entry_value[1] and type(entry_value[1]) == "string"
        and entry_value[2] and type(entry_value[2]) == "table"
end

---@param sequence string
function utils.splitKeysIntoTable(sequence)
    -- lua unfortunately has no '|' (or) operator in regex, so I make multiple and iterate
    local regexes = { '^(<[^<>]+>)', '^(<[^<>]+[<>]>)', '^.' }

    local keys = {}
    local i = 1
    while i <= #sequence do
        for _, regex in ipairs(regexes) do
            local next_key = sequence:match(regex, i)
            if next_key then
                table.insert(keys, next_key)
                i = i + #next_key
                break
            end
        end
    end

    return keys
end

---@param sequence string
function utils.splitFirstKey(sequence)
    local keys = utils.splitKeysIntoTable(sequence)
    return keys[1], table.concat(keys, "", 2)
end

return utils
