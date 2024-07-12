local utils = require 'command.utils'
local string_util = require 'string'
local FeedbackView = require 'gui.feedback.View'
local reaper_state = require 'utils.reaper_state'
local model = require 'gui.feedback.model'
local config = require 'definitions.config'.general
local feedback = {}

function feedback.displayCompletions(future_entries)
    if not future_entries then return end
    local completions = {}

    for action_type, future_entries_for_action_type in pairs(future_entries) do
        for key_sequence, entry_value in pairs(future_entries_for_action_type) do
            local completion = {}
            local duplicate_folder = false
            if utils.isFolder(entry_value) then
                completion.folder = true
                local folder_name = entry_value[1]
                completion.value = folder_name

                for i, v in pairs(completions) do
                    if v.folder and v.value == folder_name and v.key_sequence == key_sequence then
                        duplicate_folder = true
                        break
                    end
                end
            else
                completion.value = entry_value
            end

            completion.action_type = action_type
            completion.key_sequence = key_sequence

            if not completion.folder or not duplicate_folder then
                table.insert(completions, completion)
            end
        end

        table.sort(completions, function(a, b)
            if a.folder and not b.folder then return true end
            if not a.folder and b.folder then return false end
            if not a.folder and not b.folder and a.action_type ~= b.action_type then
                return a.action_type > b.action_type
            end
            return a.value < b.value
        end)

        model.setKeys({ completions = completions })
    end
end

local startup_msg =
    "Hello from inside Reaper Keys! I see the feedback window just opened... " ..
    "Here are some things I have been told to tell you:\n" ..
    "- If the feedback window is focused and not docked, I can't hear keys being pressed, be sure to unfocus it.\n" ..
    "- Press <CM-x> (Ctrl + Alt + x) to open up a keybinding menu.\n" ..
    "- Everything you need to configure reaper-keys is in REAPER/Scripts/reaper-keys/internal/definitions/\n" ..
    "- If you would like to hide this message, set the option in internal/definitions/config.lua\n" ..
    "\t Your mother loves you"
local feedback_view = nil

function feedback.update()
    local feedback_view_open = model.getKey("open")
    local just_opened = reaper_state.clearJustOpenedFlag()

    if feedback_view_open and not just_opened then
        local update_number = tonumber(model.getKey("update_number") or 0)
        if update_number > 20 then update_number = 0 end
        model.setKeys({ update_number = update_number + 1 })
        return
    end

    feedback_view = FeedbackView:new()
    feedback_view:open()

    if config.show_start_up_message then
        reaper.ShowMessageBox(startup_msg, "Reaper Keys Open Message", 1)
    end

    model.setKeys({ open = true })

    if config.profile then
        local path = '/Scripts/ReaTeam Scripts/Development/cfillion_Lua profiler.lua'
        Profiler = dofile(reaper.GetResourcePath() .. path)
        Profiler.attachToWorld()
        Profiler.start()
        Profiler.run()
    end

    reaper.atexit(function()
        model.setKeys({ open = false })
        local window_settings = feedback_view:getWindowSettings()
        model.setKeys({ window_settings = window_settings })
    end)
end

function feedback.displayMessage(message)
    model.setKeys({ message = message })
end

function feedback.displayState(state)
    local right_text = state.macro_recording
        and string_util.format("(rec %s..)", state['macro_register'])
        or ""
    model.setKeys({ right_text = right_text, mode = state['mode'] })
end

function feedback.clear()
    model.setKeys({ message = "", completions = "", mode = "" })
end

return feedback
