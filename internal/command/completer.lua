local action_sequences = require('command.action_sequences')
local utils = require('command.utils')
local definitions = require('utils.definitions')
local log = require('utils.log')

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

local function getPossibleFutureEntries(state)
    local sequences = action_sequences.getPossibleActionSequences(state)
    if not sequences then return nil end
    local entries = definitions.getPossibleEntries(state.context)
    if not entries then return nil end

    local future_entries = {}
    local future_entry_exists = false
    for _, action_sequence in pairs(sequences) do
        local next_action_type_for_sequence, entries_for_sequence = getFutureEntriesOnActionSequence(
        state['key_sequence'], action_sequence, entries)

        if entries_for_sequence then
            future_entry_exists = true
            if not future_entries[next_action_type_for_sequence] then
                future_entries[next_action_type_for_sequence] = entries_for_sequence
            else
                for key, entry in pairs(entries_for_sequence) do
                    future_entries[next_action_type_for_sequence][key] = entry
                end
            end
        end
    end

    if future_entry_exists then return future_entries end
    return nil
end
return getPossibleFutureEntries
