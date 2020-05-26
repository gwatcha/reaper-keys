local constants = {
  reset_state = {
    key_sequence = "",
    context = "main",
    mode = "normal",
    macro_recording = false,
    macro_register = "+",
    macro_commands = {},
    timeline_selection_side = "left",
    last_searched_track_name = "^$",
    last_track_name_search_direction_was_forward = true,
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
