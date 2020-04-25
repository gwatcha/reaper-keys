local startCompletionHints = require("display.completion_hints")
local definitions = require("definitions")

if new_state['key_sequence'] ~= "" then
  local completions = logic.getCompletions(new_state)
  if completions then
    startCompletionHints(completions)
  end
end
