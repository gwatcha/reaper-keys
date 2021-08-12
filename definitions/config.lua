-- behaviour configuration options, see
-- https://gwatcha.github.io/reaper-keys/configuration/behaviour.html

return {
  use_extended_defaults = false,
  show_start_up_message = true,
  -- should the auto-complete menu display?
  show_feedback_window = true,
  -- should operators in visual modes reset the selection or have it persist?
  persist_visual_timeline_selection = true,
  persist_visual_track_selection = false,
  -- allow timeline movement when in visual track mode?
  allow_visual_track_timeline_movement = true,
  -- options in decreasing verbosity: [trace debug info warn user error fatal]
  log_level = 'user',
  repeatable_commands_action_type_match = {
    'command',
    'operator',
    'meta_command',
  }
}

