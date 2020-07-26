local constants = {
  reset_state = {
    key_sequence = "",
    context = "main",
    mode = "normal",
    macro_recording = false,
    macro_register = "+",
    timeline_selection_side = "left",
    last_searched_track_name = "^$",
    last_track_name_search_direction_was_forward = true,
    visual_track_pivot_i = 0,
    last_command = {
      context = "main",
      mode = "normal",
      action_keys = {
        "NoOp"
      },
      action_sequence = {
        "command"
      }
    },
    action_list_window = {
      w = 600,
      h = 850,
      x = 1000,
      y = 200,
      dock = 0,
    }
  }
}

return constants
