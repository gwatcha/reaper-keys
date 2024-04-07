return {
  show_start_up_message = false, -- TODO should be true by default
  show_feedback_window = true,

  -- should operators in visual modes reset the selection or have it persist?
  persist_visual_timeline_selection = true,

  persist_visual_track_selection = false,

  allow_timeline_movement_in_visual_mode = true,

  -- options in decreasing verbosity: [trace debug info warn user error fatal]
  log_level = 'debug',

  -- TODO ?
  repeatable_commands_action_type_match = {
    'command',
    'operator',
    'meta_command',
  }
}

