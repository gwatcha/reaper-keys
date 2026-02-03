local root = debug.getinfo(1, 'S').source:match ".*reaper.keys[^\\/]*[\\/]":sub(2)
package.path = root .. "internal/?.lua;" .. root .. "vendor/?.lua;" .. root .. "vendor/scythe/?.lua"

---@class KeyPress
---@field key string
---@field context Context

local actions = require 'definitions.actions'
local buildCommandWithCompletions = require 'build'
local config = require 'definitions.config'.general
local executeCommand = require 'execute_command'
local executeMetaCommand = require 'meta_command'
local feedback = require 'gui.feedback.controller'
local log = require 'log'
local reaper_state = require 'reaper_state'
local serpent = require 'serpent'
local utils = require 'utils'

local aliases = {
    [8] = '<BS>',
    [9] = '<TAB>',
    [13] = '<return>',
    [27] = '<ESC>',
    [32] = '<SPC>',
    [37] = '<NumLeft>',
    [38] = '<NumUp>',
    [39] = '<NumRight>',
    [40] = '<NumDown>',
    [112] = '<F1>',
    [113] = '<F2>',
    [114] = '<F3>',
    [115] = '<F4>',
    [116] = '<F5>',
    [117] = '<F6>',
    [118] = '<F7>',
    [119] = '<F8>',
    [120] = '<F9>',
    [121] = '<F10>',
    [122] = '<F11>',
    [126] = '<F15>',
    [127] = '<F16>',
    [128] = '<F17>',
    [129] = '<F18>',
    [130] = '<F19>',
    [131] = '<F20>',
    [132] = '<F21>',
    [133] = '<F22>',
    [134] = '<F23>',
    [135] = '<F24>',
    [32801] = '<PgUp>',
    [32802] = '<PgDown>',
    [32803] = '<END>',
    [32804] = '<HOME>',
    [32805] = '<left>',
    [32806] = '<up>',
    [32807] = '<right>',
    [32808] = '<down>',
    [32813] = '<INS>',
    [32814] = '<DEL>',
}
if config.use_f12_f14 then
    aliases[123] = '<F12>'
    aliases[124] = '<F13>'
    aliases[125] = '<F14>'
end

local macos = reaper.GetOS():match "OS"
local macos_shift_fix = {
    [51] = 35, --#
    [52] = 36, --$
    [53] = 37, --%
    [54] = 94, --^
    [55] = 38, --&
    [56] = 42, --*
    [57] = 40, --(
    [48] = 41, --)
}

---@param ctx string
---@return string
local function ctxToKey(ctx)
    local _, _, mod, code = ctx:find "^key:(.*):(.*)$"
    local virt, ctrl, shift = mod:match "V", mod:match "C", mod:match "S"
    local alt = mod:match "A" and "M" or nil
    code = tonumber(code) or -1
    local macos_shift_res = macos_shift_fix[code]
    if macos and virt and shift and macos_shift_res then
        virt, shift, code = false, false, macos_shift_res
    end

    -- Reaper always transmits uppercase letters. Convert them to lowercase if we don't have Shift
    if 65 <= code and code <= 90 then
        local key = string.char(code + (shift and 0 or 32))
        if not ctrl and not alt then return key end
        return ("<%s%s-%s>"):format(ctrl or "", alt or "", key)
    end

    local use_aliases = not (not virt and 37 <= code and code <= 40)
    local key = use_aliases and aliases[code] or string.char(code)
    if not ctrl and not alt and not shift then return key end
    return ("<%s%s%s-%s>"):format(ctrl or "", alt or "", shift or "", key)
end

---@param command Command
---@return boolean
local function isRepeatableCommand(command)
    for _, action_type in ipairs(command.action_sequence) do
        for _, action_type_match in ipairs(config.repeatable_commands_action_type_match) do
            if action_type:find(action_type_match) then
                return true
            end
        end
    end
    return false
end

---@param state State
---@return State
local function checkIfConsistentState(state)
    local serialized_state = reaper_state.getState()
    for key, value in pairs(serialized_state) do
        if key == 'last_command' then
            local left = serpent.line(state.last_command, { comment = false })
            local right = serpent.line(serialized_state.last_command, { comment = false })
            if left ~= right then return serialized_state end
        elseif value ~= state[key] then
            return serialized_state
        end
    end
    return state
end

---@param state State
---@param command Command
---@return State
local function handleCommand(state, command)
    local new_state = executeMetaCommand(state, command)
    if new_state then return new_state end

    executeCommand(command)

    -- internal commands may have changed the state
    state = checkIfConsistentState(state)

    if isRepeatableCommand(command) then
        state.last_command = command
    end

    if state.macro_recording then
        reaper_state.appendToMacro(state.macro_register, command)
    end

    state.key_sequence = ""
    return state
end

---@param key string
---@return string
local function removeUglyBrackets(key)
    if key:sub(1, 1) == "<" and key:sub(#key, #key) == ">" then
        return key:sub(2, #key - 1)
    end
    return key
end

---@param sequence string
---@return string
local function formatKeySequence(sequence)
    local rest = sequence
    local key_sequence_string = ""
    local first_key
    while #rest ~= 0 do
        first_key, rest = utils.splitFirstKey(rest)
        if tonumber(first_key) then
            key_sequence_string = key_sequence_string .. first_key
        else
            key_sequence_string = key_sequence_string .. " " .. removeUglyBrackets(first_key)
        end
    end

    return key_sequence_string .. "-"
end

---@param action_keys Action[]
---@return string
local function formatActionKeys(action_keys)
    local desc = ""
    for _, command_part in pairs(action_keys) do
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

---@param state State
---@param key_press KeyPress
---@return State
local function step(state, key_press)
    local new_state = state

    if state.key_sequence == "" then
        new_state.context = key_press.context
    elseif state.context ~= key_press.context then
        new_state.key_sequence = ''
        feedback.displayMessage(("Next context %s, current context %s"):format(key_press.context, state.context))
        return new_state
    end

    new_state.key_sequence = key_press.key == "<ESC>"
        and key_press.key
        or state.key_sequence .. key_press.key

    log.info(("new key sequence %s"):format(new_state.key_sequence))
    local command, completions = buildCommandWithCompletions(new_state, true)
    if command then
        log.trace(("command built: %s"):format(serpent.block(command, { comment = false})))

        reaper.Undo_BeginBlock2(0)
        new_state = handleCommand(new_state, command)
        local description = formatActionKeys(command.action_keys)
        reaper.Undo_EndBlock2(0, ('reaper-keys: %s'):format(description), 1)

        if config.show_feedback_window then
            feedback.displayMessage(description)
        end
        return new_state
    end

    if not config.show_feedback_window then
        return new_state
    end

    if not completions then
        feedback.displayMessage(("Undefined key sequence %s"):format(new_state.key_sequence))
        new_state.key_sequence = ''
        return new_state
    end

    feedback.displayMessage(formatKeySequence(state.key_sequence))
    feedback.displayCompletions(completions)
    return new_state
end

local function reaperKeys()
    local _, _, section_id, _, _, _, _, ctx = reaper.get_action_context()
    if ctx == "" then return end
    local main_ctx = section_id == 0
    ---@type KeyPress
    local hotkey = { context = main_ctx and "main" or "midi", key = ctxToKey(ctx) }

    log.info(("Input: %s"):format(serpent.line(hotkey, { comment = false })))
    if config.show_feedback_window then feedback.clear() end

    local state = reaper_state.getState()
    local new_state = step(state, hotkey)
    reaper_state.setState(new_state)

    log.info(("New state: %s"):format(serpent.block(new_state, {comment = false})))
    if not config.show_feedback_window then return end

    feedback.displayState(new_state)

    -- If window is floating, it's controlled by WM so we can't always defocus it
    if not config.dock_feedback_window then return end

    local defocus_window = main_ctx and actions.FocusTracks or actions.FocusMidiEditor
    reaper.Main_OnCommand(reaper.NamedCommandLookup(defocus_window), 0)

    -- When we insert track with feedback window closed, it steals focus and track is not renamed
    if not main_ctx or not new_state or new_state.key_sequence ~= "" then return end
    if not hotkey.key:lower():match "o" then return end
    local keys = new_state.last_command.action_keys
    if #keys ~= 1 or not keys[1]:match "^EnterTrack" then return end
    reaper.Main_OnCommand(actions.RenameTrack, 0)
end

local function messageHandler(err)
    log.error(debug.traceback(err))
end

xpcall(reaperKeys, messageHandler)
