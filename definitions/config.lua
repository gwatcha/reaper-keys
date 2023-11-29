return {
  show_start_up_message = false, -- TODO should be true by default

  show_feedback_window = true,

  -- should operators in visual modes reset the selection or have it persist?
  persist_visual_timeline_selection = true,

  persist_visual_track_selection = false,

  allow_timeline_movement_in_visual_mode = true,

  -- options in decreasing verbosity: [trace debug info warn user error fatal]
  -- TODO make a enum
  log_level = 'error',

  -- Logging to Reaper's message boxes is extremely slow and makes GUI unresponsive.
  -- Consider turning this setting on if log_level is info or more verbose.
  -- Log file will be available at REAPER/reaper-keys.log
  log_to_file_instead_of_message_box = false,

  -- TODO ?
  repeatable_commands_action_type_match = {
    'command',
    'operator',
    'meta_command',
  }
}

