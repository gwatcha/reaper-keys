local action_sequences = require 'action_sequence'
local definitions = require 'utils.definitions'
local log = require 'log'
local utils = require 'command.utils'

local function entryToString(entry)
    if utils.isFolder(entry) then
        return entry[1]
    end
    return entry
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

local function getPossibleFutureEntriesForKeySequence(key_sequence, entries)
    if not entries then return nil end
    if not key_sequence then return nil end

    if key_sequence == "" then return entries end

    local possible_future_entries = {}

    local number_match, key_sequence_no_number = utils.splitFirstMatch(key_sequence, '[1-9][0-9]*')
    if number_match then
        local number_prefix_entries = utils.filterEntries({ "prefixRepetitionCount" }, entries)
        local possible_future_entries_if_number_prefix = getPossibleFutureEntriesForKeySequence(key_sequence_no_number,
            number_prefix_entries)
        mergeEntries(possible_future_entries, possible_future_entries_if_number_prefix)
    end

    for entry_key_sequence, entry_val in pairs(entries) do
        local completion_sequence = utils.stripBegginingKeys(entry_key_sequence, key_sequence)
        if completion_sequence then
            possible_future_entries[completion_sequence] = entry_val
        end
        if utils.isFolder(entry_val) then
            local folder = entry_val
            MergeFutureEntriesWithFolder(possible_future_entries, key_sequence, entry_key_sequence, folder)
        else
            local action_name = entry_val
            if key_sequence == entry_key_sequence and utils.checkIfActionHasOptionSet(action_name, 'registerAction') then
                possible_future_entries["(key)"] = "(register)"
            end
        end
    end

    if next(possible_future_entries) == nil then
        return nil
    end

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

local function getFutureEntriesOnActionSequence(key_sequence, action_sequence, entries)
    if #action_sequence == 0 then return nil end

    local current_action_type = action_sequence[1]

    local entries_for_current_action_type = entries[current_action_type]
    if not entries_for_current_action_type then return nil end
    if key_sequence == "" then
        return current_action_type, entries_for_current_action_type
    end

    local completions = getPossibleFutureEntriesForKeySequence(key_sequence, entries_for_current_action_type)
    if completions then
        return current_action_type, completions
    end

    local rest_of_sequence = key_sequence
    local key_sequence_to_try = ""
    local next_key = nil

    while #rest_of_sequence ~= 0 do
        next_key, rest_of_sequence = utils.splitFirstKey(rest_of_sequence)
        key_sequence_to_try = key_sequence_to_try .. next_key
        local entry = utils.getEntryForKeySequence(key_sequence_to_try, entries_for_current_action_type)

        if entry then
            table.remove(action_sequence, 1)
            return getFutureEntriesOnActionSequence(rest_of_sequence, action_sequence, entries)
        end
    end

    return nil
end

local function getActionKey(key_sequence, entries)
    local action_name = utils.getEntryForKeySequence(key_sequence, entries)
    local no_register =
        not utils.checkIfActionHasOptionSet(action_name, 'registerAction')
        or utils.checkIfActionHasOptionSet(action_name, 'registerOptional')

    if action_name and not utils.isFolder(action_name) and no_register then return action_name end

    local number_match, rest_of_key_sequence = utils.splitFirstMatch(key_sequence, '[1-9][0-9]*')
    if number_match then
        local num_prefix_entries = utils.filterEntries({ "prefixRepetitionCount" }, entries)
        local action_key = getActionKey(rest_of_key_sequence, num_prefix_entries)
        if action_key then
            if type(action_key) ~= 'table' then action_key = { action_key } end
            action_key['prefixedRepetitions'] = tonumber(number_match)
            return action_key
        end
    end

    local start_of_key_sequence, possible_register = utils.splitLastKey(key_sequence)
    local reg_postfix_entries = utils.filterEntries({ "registerAction" }, entries)
    local register_action_name = utils.getEntryForKeySequence(start_of_key_sequence, reg_postfix_entries)
    if register_action_name and not utils.isFolder(register_action_name) then
        local action_key = { register_action_name }
        action_key['register'] = possible_register
        return action_key
    end

    return nil
end

local function stripNextActionKeyInKeySequence(key_sequence, action_type_entries)
    if not action_type_entries then return nil, nil, false end

    local rest_of_key_sequence = ""
    local key_sequence_for_action_type = key_sequence
    while #key_sequence_for_action_type ~= 0 do
        local action_key = getActionKey(key_sequence_for_action_type, action_type_entries)
        if action_key then return rest_of_key_sequence, action_key, true end

        local last_key
        key_sequence_for_action_type, last_key = utils.splitLastKey(key_sequence_for_action_type)
        rest_of_key_sequence = last_key .. rest_of_key_sequence
    end

    return nil, nil, false
end

local function buildCommandWithSequence(key_sequence, action_sequence, entries)
    local command = { action_sequence = {}, action_keys = {} }
    local rest_of_key_sequence = key_sequence

    for _, action_type in pairs(action_sequence) do
        local action_key, found
        rest_of_key_sequence, action_key, found = stripNextActionKeyInKeySequence(
            rest_of_key_sequence, entries[action_type])
        if not found then return nil end
        table.insert(command.action_sequence, action_type)
        table.insert(command.action_keys, action_key)
    end

    if #rest_of_key_sequence > 0 then return nil end
    return command
end

---@param state State
---@param build boolean if false, just suggest completions
---@return Command?, Completion[]?
local function buildCommandWithCompletions(state, build)
    local sequences = action_sequences.action_sequence_keys[state.context][state.mode]
    local entries = definitions.getPossibleEntries(state.context)
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
    if not sequences or not entries then return nil, nil end

    local future_entries = {}
    local exists = false
    for _, action_sequence in pairs(sequences) do
        local next_action_type_for_sequence, entries_for_sequence = getFutureEntriesOnActionSequence(
            state.key_sequence, action_sequence, entries)

        if entries_for_sequence then
            exists = true
            if not future_entries[next_action_type_for_sequence] then
                future_entries[next_action_type_for_sequence] = entries_for_sequence
            else
                for key, entry in pairs(entries_for_sequence) do
                    future_entries[next_action_type_for_sequence][key] = entry
                end
            end
        end
    end

    if exists then return nil, future_entries end
    return nil, nil
end

return buildCommandWithCompletions
