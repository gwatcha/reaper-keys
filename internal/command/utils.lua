local utils = {}

function utils.isFolder(entry_value)
  if entry_value then
    if entry_value[1] and type(entry_value[1]) == "string" then
      if entry_value[2] and type(entry_value[2]) == "table" then
        return true
      end
    end
  end

  return false
end

function utils.splitKeysIntoTable(key_sequence)
  -- lua unfortunately has no '|' (or) operator in regex, so I make multiple and iterate
  local key_capture_regex = {'^(<[^<>]+>)', '^(<[^<>]+[<>]>)', '^.'}

  local keys = {}
  local i = 1
  while i <= #key_sequence do
    for _,capture_regex in ipairs(key_capture_regex) do
      local next_key = string.match(key_sequence, capture_regex, i)
      if next_key then
        table.insert(keys, next_key)
        i = i + #next_key
        break
      end
    end
  end

  return keys
end

function utils.splitFirstKey(key_sequence)
  local keys = utils.splitKeysIntoTable(key_sequence)
  return keys[1], table.concat(keys, "", 2)
end

return utils
