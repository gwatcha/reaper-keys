local constants = {
  reset_state = {
    key_sequence = "",
    context = "main",
    mode = "normal",
    macro_recording = false,
    macro_register = "+",
    macro_commands = {},
    timeline_selection_side = "left",
    last_command = {
      context = "main",
      mode = "normal",
      parts = {
        "NoOp"
      },
      sequence = {
        "command"
      }
    }
  }
}

return constants
