local state_interface = require('state_machine.state_interface')
local buildCommand = require('command.builder')
local handleCommand = require('command.handler')
local getPossibleFutureEntries = require('command.completer')
local show_feedback_window = require 'definitions.config'.general.show_feedback_window
local log = require('utils.log')
local format = require('utils.format')
local feedback = require('gui.feedback.controller')

local function updateWithKeyPress(state, key_press)
    local new_state = state
    if state.key_sequence == "" then
        new_state.context = key_press.context
    elseif state.context ~= key_press.context then
        return nil, 'Undefined key sequence. Next key is in different context.'
    end

    local new_key_sequence = state.key_sequence .. key_press.key
    new_state.key_sequence = new_key_sequence

    return new_state, nil
end

local function step(state, key_press)
    local message = ""
    local new_state, err = updateWithKeyPress(state, key_press)
    if err ~= nil then
        new_state = state
        new_state.key_sequence = ''
        feedback.displayMessage(err)
        return new_state
    end

    log.info("New key sequence: " .. new_state.key_sequence)
    local command = buildCommand(new_state)
    if command then
        log.trace("Command built: " .. format.block(command))
        new_state, message = handleCommand(new_state, command)
        feedback.displayMessage(message)
        return new_state
    end

    local future_entries = getPossibleFutureEntries(new_state)
    if not future_entries then
        feedback.displayMessage(
            ("Undefined key sequence %s"):format(new_state.key_sequence))
        new_state.key_sequence = ''
        return new_state
    end

    message = format.keySequence(state.key_sequence, true) .. "-"
    feedback.displayMessage(message)
    feedback.displayCompletions(future_entries)

    return new_state
end
-- FIXME backspace should remove last cmd part
-- FIXME cmd_part + ESC doesn't cause an immediate reset
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
    [112] = 'F1',
    [113] = 'F2',
    [114] = 'F3',
    [115] = 'F4',
    [116] = 'F5',
    [117] = 'F6',
    [118] = 'F7',
    [119] = 'F8',
    [120] = 'F9',
    [121] = 'F10',
    [122] = 'F11',
    [123] = 'F12',
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

local function ctxToState(ctx)
    local _, _, mod, code = ctx:find "^key:V?(.*):(.*)$"
    local ctrl, shift = mod:match "C", mod:match "S"
    local alt = mod:match "A" and "M" or nil
    code = tonumber(code) or -1

    if 65 <= code and code <= 90 then
        -- Reaper transmits uppercase letters, lowercase them
        local key = string.char(code + (shift and 0 or 32))
        if not ctrl and not alt then return key end
        return ("<%s%s-%s>"):format(ctrl or "", alt or "", key)
    end
    local key = aliases[code] or string.char(code)
    if mod == '' then return key end
    return ("<%s%s%s-%s>"):format(ctrl or "", alt or "", shift or "", key)
end

local function input()
    local _, _, section_id, _, _, _, _, ctx = reaper.get_action_context()
    if ctx == "" then return end
    local hotkey = { context = section_id == 0 and "main" or "midi", key = ctxToState(ctx) }

    log.info("Input: " .. format.line(hotkey))
    if show_feedback_window then feedback.clear() end

    local state = state_interface.get()
    local new_state = step(state, hotkey)
    state_interface.set(new_state)

    if show_feedback_window then
        feedback.displayState(new_state)
        feedback.update()
    end

    log.info("new state: " .. format.block(new_state))
end

return input
