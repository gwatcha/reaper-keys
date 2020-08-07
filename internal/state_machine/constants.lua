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
    binding_list = {
      w = 600,
      h = 850,
      state_filter_active = true,
      context_filter_active = false,
      context_filter = 1,
      type_filter_active = false,
      type_filter = 1,
    }
  }
}

return constants
