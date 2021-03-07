-- behaviour configuration options, see
-- https://gwatcha.github.io/reaper-keys/configuration/behaviour.html

return {
  -- should operators in visual modes reset the selection or have it persist?
  persist_visual_timeline_selection = false,
  persist_visual_track_selection = false,
  -- allow timeline movement when in visual track mode?
  allow_visual_track_timeline_movement = true,
  -- options in decreasing verbosity: [trace debug info warn user error fatal]
  log_level = 'user',
  repeatable_commands_action_type_match = {
    'command',
    'operator',
    'meta_command',
  },

  -- create you custom name prefix
  name_prefix_match_str = '^%a%:.*%:'
}
