return {
  -- should operators in visual modes reset the selection or have it persist?
  persist_visual_timeline_selection = true,
  persist_visual_track_selection = false,
  -- allow timeline movement when in visual track mode
  allow_visual_track_timeline_movement = true,
  -- options in decreasing verbosity: [trace debug info warn user error fatal]
  log_level = 'warn',
  repeatable_commands_action_type_match = {
    'command',
    'operator',
    'meta_command',
  }
}

