local utils = require('command.utils')
local str = require('string')
local model_interface = require('gui.feedback.model_interface')

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
      if a.action_type == b.action_type then
        return a.value < b.value
      else
        return a.action_type > b.action_type
      end
    end
    table.sort(completions, alphabetical_sort)

    model_interface.write({completions = completions})
  end
end

function feedback.update()
  local model = model_interface.read()
  if not model.update_number or model.update_number > 20 then
    model.update_number = 0
  end
  model_interface.write({
      update_number = model.update_number + 1
  })
end

function feedback.displayMessage(message)
  model_interface.write({
      message= message
  })
end

function feedback.displayState(state)
  local right_text = ""
  if state['macro_recording'] then
    right_text = str.format("(rec %s..)", state['macro_register'])
  end

  model_interface.write({
      right_text = right_text,
      mode = state['mode']
  })
end

function feedback.clear()
  model_interface.write({
      message = "",
      completions = "",
      mode = "",
  })
end

return feedback
