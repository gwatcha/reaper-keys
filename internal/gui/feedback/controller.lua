local utils = require('command.utils')
local string_util = require('string')
local FeedbackView = require('gui.feedback.View')
local reaper_state = require('utils.reaper_state')
local model = require('gui.feedback.model')
local config = require('definitions.config')

local feedback = {}

function feedback.displayCompletions(future_entries)
  if not future_entries then
    return
  end

  local completions = {}

  for action_type,future_entries_for_action_type in pairs(future_entries) do
    for key_sequence,entry_value in pairs(future_entries_for_action_type) do
      local completion = {}
      local duplicate_folder = false
      if utils.isFolder(entry_value) then
        completion.folder = true
        local folder_name = entry_value[1]
        completion.value = folder_name

        for i,v in pairs(completions) do
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

    local alphabetical_sort = function(a, b)
      if a.folder and not b.folder then
        return true
      elseif not a.folder and b.folder then
        return false
      elseif not a.folder and not b.folder and a.action_type ~= b.action_type then
        return a.action_type > b.action_type
      end

      return a.value < b.value
    end
    table.sort(completions, alphabetical_sort)

    model.setKeys({completions = completions})
  end
end

function feedback.update()
  local feedback_view_open = model.getKey("open")
  local just_opened = reaper_state.clearJustOpenedFlag()

  if not feedback_view_open or just_opened then
    local feedback_view = FeedbackView:new()
    feedback_view:open()

    if config.show_start_up_message then
      reaper.ShowMessageBox("Hello from inside Reaper Keys! I see the feedback window just opened... Here are some things I have been told to tell you:\n  -If the feedback window is focused, I can't hear the keys being pressed, so be sure to unfocus it.\n  -If that pesky 'this script is running in the background hur dur' message comes up just check 'new instance' and 'remember' and it will go away\n  -Press <M-x> (Alt+x) to open up a keybinding menu.\n  -Everything you need to configure reaper-keys is in the REAPER/Scripts/reaper-keys/definitions/ directory.\n  -If you would like this message to not appear anymore, set the option in definitions/config.lua.\n  -If you set that option there will be no one to protect you from the focus stealing of the feedback window.\n  -reaper-keys uses a reduced keymap by default, if you want more keybindings, set the option in definitions/config.lua to use the extended defaults.\n  -Your mother loves you", "Reaper Keys Open Message", 1)
    end

    model.setKeys({open = true})

    reaper.atexit(function()
        model.setKeys({open  = false})
        local window_settings = feedback_view:getWindowSettings()
        model.setKeys({window_settings = window_settings})
    end)
  else
    local update_number = model.getKey("update_number")
    if not update_number or update_number > 20 then
      update_number = 0
    end
    model.setKeys({update_number = update_number + 1})
  end
end

function feedback.displayMessage(message)
  model.setKeys({message = message})
end

function feedback.displayState(state)
  local right_text = ""
  if state['macro_recording'] then
    right_text = string_util.format("(rec %s..)", state['macro_register'])
  end

  model.setKeys({right_text = right_text, mode = state['mode']})
end

function feedback.clear()
  model.setKeys({
      message = "",
      completions = "",
      mode = "",
  })
end

return feedback
