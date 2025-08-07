local root = debug.getinfo(1, 'S').source:match ".*reaper.keys[^\\/]*[\\/]":sub(2)
package.path = root .. "internal/?.lua;" .. root .. "vendor/?.lua;" .. root .. "vendor/scythe/?.lua"

local state_interface = require 'state_machine.state_interface'
local buildCommand = require 'command.builder'
local handleCommand = require 'command.handler'
local getPossibleFutureEntries = require 'command.completer'
local config = require 'definitions.config'.general
local actions = require 'definitions.actions'
local log = require 'log'
local format = require 'utils.format'
local feedback = require 'gui.feedback.controller'

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
    [123] = '<F12>',
    [124] = '<F13>',
    [125] = '<F14>',
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
local function ctxToKey(ctx)
    local _, _, mod, code = ctx:find "^key:(.*):(.*)$"
    local virt, ctrl, shift = mod:match "V", mod:match "C", mod:match "S"
    local alt = mod:match "A" and "M" or nil
    code = tonumber(code) or -1
    local macos_shift_res = macos_shift_fix[code]
    if macos and virt and shift and macos_shift_res then
        virt, shift, code = false, false, macos_shift_res
    end

    -- Reaper always transmits uppercase letters. Convert them to lowecase if we don't have Shift
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

---append the keypress to the key sequence and build a command.
---If there’s a command, execute it.
---If there’s no command, check that there are possible future action-entries that could be triggered.
---if there’s no possible future action-entries, reset the keysequence to empty and raise an error
---return the updated state
---@param state State
---@param key_press KeyPress
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
    local command = buildCommand(new_state)
    if command then
        local message
        log.trace(("command built: %s"):format(format.block(command)))
        new_state, message = handleCommand(new_state, command)
        feedback.displayMessage(message)
        return new_state
    end

    local completions = getPossibleFutureEntries(new_state)
    if not completions then
        feedback.displayMessage(("Undefined key sequence %s"):format(new_state.key_sequence))
        new_state.key_sequence = ''
        return new_state
    end

    feedback.displayMessage(format.keySequence(state.key_sequence))
    feedback.displayCompletions(completions)
    return new_state
end

local function reaperKeys()
    local _, _, section_id, _, _, _, _, ctx = reaper.get_action_context()
    if ctx == "" then return end
    local main_ctx = section_id == 0
    ---@type KeyPress
    local hotkey = { context = main_ctx and "main" or "midi", key = ctxToKey(ctx) }

    log.info(("Input: %s"):format(format.line(hotkey)))
    if config.show_feedback_window then feedback.clear() end

    local state = state_interface.get()
    local new_state = step(state, hotkey)
    state_interface.set(new_state)

    log.info(("New state: %s"):format(format.block(new_state)))
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
