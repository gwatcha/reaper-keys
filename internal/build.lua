local action_sequences = require 'action_sequence'
local actions = require "definitions.actions"
local bindings = require "definitions.bindings"
local log = require 'log'
local utils = require 'utils'

local function entryToString(entry)
    return utils.isFolder(entry) and entry[1] or entry
end

local function mergeEntries(t1, t2)
    if not t2 then return t1 end
    for key_seq, entry_val in pairs(t2) do
        if t1[key_seq] then
            log.warn("Found key clash for action_sequence " ..
            key_seq .. " : " .. entryToString(t1[key_seq]) .. " and " .. entryToString(entry_val))
        end
        t1[key_seq] = entry_val
    end
end

---@param str string
---@param prefix string
---@return string?
local function stripPrefix(str, prefix)
    if #prefix >= #str then return nil end
    if #prefix == 0 then return str end
    local next_key, next_key_in_start, rest
    for _ = 1, #prefix do
        next_key, rest = utils.splitFirstKey(str)
        next_key_in_start, _ = utils.splitFirstKey(prefix)
        if next_key_in_start ~= next_key then return nil end
    end
    return rest
end

local function checkIfActionHasOptionSet(action_name, option_name)
    if utils.isFolder(action_name) then return false end
    local action = actions[action_name]
    return action and type(action) == 'table' and action[option_name]
end

local function checkIfActionHasOptionsSet(action_name, option_names)
  if utils.isFolder(action_name) then return false end
  for _, option_name in ipairs(option_names) do
    if not checkIfActionHasOptionSet(action_name, option_name) then
      return false
    end
  end
  return true
end

local function filterEntries(options, entries)
  local filtered_entries = {}
  for key_seq,entry_val in pairs(entries) do
    if utils.isFolder(entry_val) then
      local folder = entry_val
      local folder_name = folder[1]
      local folder_table = folder[2]
      local filtered_entries_for_folder = filterEntries(options, folder_table)
      if next(filtered_entries_for_folder) ~= nil then
        filtered_entries[key_seq] = {folder_name, filtered_entries_for_folder}
      end
    else
      local action_name = entry_val
      if checkIfActionHasOptionsSet(action_name, options) then
        filtered_entries[key_seq] = entry_val
      end
    end
  end

  return filtered_entries
end

---@param key_sequence string
---@param match_regex string
---@return string?, string
local function splitFirstMatch(key_sequence, match_regex)
    local match = key_sequence:match(match_regex)
    if not match then return nil, key_sequence end
    return match, key_sequence:sub(match:len() + 1)
end

local function getPossibleFutureEntriesForKeySequence(key_sequence, entries)
    if not entries then return nil end
    if not key_sequence then return nil end
    if key_sequence == "" then return entries end

    local possible_future_entries = {}

    local number_match, key_sequence_no_number = splitFirstMatch(key_sequence, '[1-9][0-9]*')
    if number_match then
        local number_prefix_entries = filterEntries({ "prefixRepetitionCount" }, entries)
        local possible_future_entries_if_number_prefix = getPossibleFutureEntriesForKeySequence(key_sequence_no_number,
            number_prefix_entries)
        mergeEntries(possible_future_entries, possible_future_entries_if_number_prefix)
    end

    for entry_key_sequence, entry_val in pairs(entries) do
        local completion_sequence = stripPrefix(entry_key_sequence, key_sequence)
        if completion_sequence then
            possible_future_entries[completion_sequence] = entry_val
        end
        if utils.isFolder(entry_val) then
            local folder = entry_val
            MergeFutureEntriesWithFolder(possible_future_entries, key_sequence, entry_key_sequence, folder)
        else
            local action_name = entry_val
            if key_sequence == entry_key_sequence and checkIfActionHasOptionSet(action_name, 'registerAction') then
                possible_future_entries["(key)"] = "(register)"
            end
        end
    end

    if next(possible_future_entries) == nil then return nil end
    return possible_future_entries
end

function MergeFutureEntriesWithFolder(possible_future_entries, key_sequence, folder_key_sequence, folder)
    local folder_table = folder[2]
    if folder_key_sequence == key_sequence then
        mergeEntries(possible_future_entries, folder_table)
        return
    end

    local first_key, rest_of_sequence = utils.splitFirstKey(key_sequence)
    if folder_key_sequence == first_key then
        local future_entries_from_folder = getPossibleFutureEntriesForKeySequence(rest_of_sequence, folder_table)
        mergeEntries(possible_future_entries, future_entries_from_folder)
        return
    end
end

local function getEntryForKeySequence(key_sequence, entries)
  local entry = entries[key_sequence]
  if entry and not utils.isFolder(entry) then return entry end
  local first_key, rest_of_key_sequence = utils.splitFirstKey(key_sequence)
  local possible_folder = entries[first_key]
  if rest_of_key_sequence and utils.isFolder(possible_folder) then
    local folder_table = possible_folder[2]
    return getEntryForKeySequence(rest_of_key_sequence,  folder_table)
  end
  return nil
end

local function getFutureEntriesOnActionSequence(key_sequence, action_sequence, entries)
    if #action_sequence == 0 then return nil end

    local current_action_type = action_sequence[1]

    local entries_for_current_action_type = entries[current_action_type]
    if not entries_for_current_action_type then return nil end
    if key_sequence == "" then
        return current_action_type, entries_for_current_action_type
    end

    local completions = getPossibleFutureEntriesForKeySequence(key_sequence, entries_for_current_action_type)
    if completions then return current_action_type, completions end

    local rest_of_sequence = key_sequence
    local key_sequence_to_try = ""
    local next_key = nil

    while #rest_of_sequence ~= 0 do
        next_key, rest_of_sequence = utils.splitFirstKey(rest_of_sequence)
        key_sequence_to_try = key_sequence_to_try .. next_key
        local entry = getEntryForKeySequence(key_sequence_to_try, entries_for_current_action_type)

        if entry then
            table.remove(action_sequence, 1)
            return getFutureEntriesOnActionSequence(rest_of_sequence, action_sequence, entries)
        end
    end

    return nil
end

local function splitLastKey(key_sequence)
    local keys = utils.splitKeysIntoTable(key_sequence)
    return table.concat(keys, "", 1, #keys - 1), keys[#keys]
end

local function getActionKey(key_sequence, entries)
    local action_name = getEntryForKeySequence(key_sequence, entries)
    local no_register =
        not checkIfActionHasOptionSet(action_name, 'registerAction')
        or checkIfActionHasOptionSet(action_name, 'registerOptional')

    if action_name and not utils.isFolder(action_name) and no_register then return action_name end

    local number_match, rest_of_key_sequence = splitFirstMatch(key_sequence, '[1-9][0-9]*')
    if number_match then
        local num_prefix_entries = filterEntries({ "prefixRepetitionCount" }, entries)
        local action_key = getActionKey(rest_of_key_sequence, num_prefix_entries)
        if action_key then
            if type(action_key) ~= 'table' then action_key = { action_key } end
            action_key['prefixedRepetitions'] = tonumber(number_match)
            return action_key
        end
    end

    local start_of_key_sequence, possible_register = splitLastKey(key_sequence)
    local reg_postfix_entries = filterEntries({ "registerAction" }, entries)
    local register_action_name = getEntryForKeySequence(start_of_key_sequence, reg_postfix_entries)
    if register_action_name and not utils.isFolder(register_action_name) then
        local action_key = { register_action_name }
        action_key['register'] = possible_register
        return action_key
    end

    return nil
end

local function stripNextActionKeyInKeySequence(key_sequence, action_type_entries)
    if not action_type_entries then return nil, nil end

    local rest_of_key_sequence = ""
    local key_sequence_for_action_type = key_sequence
    while #key_sequence_for_action_type ~= 0 do
        local action_key = getActionKey(key_sequence_for_action_type, action_type_entries)
        if action_key then return rest_of_key_sequence, action_key end

        local last_key
        key_sequence_for_action_type, last_key = splitLastKey(key_sequence_for_action_type)
        rest_of_key_sequence = last_key .. rest_of_key_sequence
    end

    return nil, nil
end

---@param t1 table
---@param t2 table
---@return table
local function concatEntries(t1, t2)
  local merged_entries = {}
  for key_sequence,entry_value in pairs(t1) do
    merged_entries[key_sequence] = entry_value
  end

  for key_sequence,t2_value in pairs(t2) do
    local merged_value = t2_value
    if t2_value == "" then
      merged_value = nil
    end

    local t1_value = merged_entries[key_sequence]
    if utils.isFolder(t2_value) and utils.isFolder(t1_value) and t1_value[1] == t2_value[1] then
        local folder_1_entries = t1_value[2]
        local folder_2_entries = t2_value[2]
        merged_value = {
          t2_value[1],
          concatEntries(folder_1_entries, folder_2_entries),
        }
    end

    merged_entries[key_sequence] = merged_value
  end

  return merged_entries
end

---@param t1 table
---@param t2 table
---@return table
local function concatEntryTables(t1,t2)
  local merged_tables = t1
  for action_type, _ in pairs(t1) do
    if t2[action_type] then
      local merged = concatEntries(t1[action_type], t2[action_type])
      merged_tables[action_type] = merged
    end
  end

  for action_type, entries in pairs(t2) do
    if not merged_tables[action_type] then
      merged_tables[action_type] = entries
    end
  end

  return merged_tables
end

---@type table<Context, Definition[]>
local possible_entries = {
    global = concatEntryTables({}, bindings.global),
    midi = concatEntryTables(concatEntryTables({}, bindings.global), bindings.midi),
    main = concatEntryTables(concatEntryTables({}, bindings.global), bindings.main),
}

---@return Command?
local function buildCommandWithSequence(key_sequence, action_sequence, entries)
    local command = { action_sequence = {}, action_keys = {} }
    local action_key
    local tail = key_sequence

    for _, action_type in pairs(action_sequence) do
        tail, action_key = stripNextActionKeyInKeySequence(tail, entries[action_type])
        if not tail then return nil end
        table.insert(command.action_sequence, action_type)
        table.insert(command.action_keys, action_key)
    end

    return #tail == 0 and command or nil
end

---@param state State
---@param build boolean if false, just suggest completions
---@return Command?, Completion[]?
local function buildCommandWithCompletions(state, build)
    local sequences = action_sequences.action_sequence_keys[state.context][state.mode]
    local entries = possible_entries[state.context]
    if not sequences or not entries then return nil, nil end
    if not build then goto build_completions end

    for _, action_sequence in pairs(sequences) do
        local command = buildCommandWithSequence(state.key_sequence, action_sequence, entries)
        if command then
            command.mode = state.mode
            command.context = state.context
            return command, nil
        end
    end

::build_completions::
    local future_entries = {}
    local found = false

    for _, action_sequence in pairs(sequences) do
        local next_action_type_for_sequence, entries_for_sequence = getFutureEntriesOnActionSequence(
            state.key_sequence, action_sequence, entries)
        if not entries_for_sequence then goto next_sequence_complete end
        found = true

        if not future_entries[next_action_type_for_sequence] then
            future_entries[next_action_type_for_sequence] = entries_for_sequence
        else
            for key, entry in pairs(entries_for_sequence) do
                future_entries[next_action_type_for_sequence][key] = entry
            end
        end
::next_sequence_complete::
    end

    return nil, found and future_entries or nil
end

return buildCommandWithCompletions
