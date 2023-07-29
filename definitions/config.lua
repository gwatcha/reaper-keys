return {
  -- TODO remove (add non-extended defaults as an example actions2.lua)
  use_extended_defaults = true,

  -- TODO should be true by default
  show_start_up_message = false,

  show_feedback_window = true,

  -- should operators in visual modes reset the selection or have it persist?
  persist_visual_timeline_selection = true,

  persist_visual_track_selection = false,

  -- allow timeline movement when in visual track mode?
  allow_visual_track_timeline_movement = true,

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

