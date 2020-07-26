return {
  -- should operators in visual modes reset the selection or have it persist?
  persist_visual_timeline_selection = true,
  persist_visual_track_selection = false,
  -- allow timeline movement when in visual track mode
  allow_visual_track_timeline_movement = true,
  -- options in decreasing verbosity: [trace debug info warn user error fatal]
  log_level = 'userj',
  -- the factor to scale all gui elements (font size, element sizes...) 
  -- will be multiplied by 2 if HiDPI mode is detected
  gui_scale = 1,
  action_list = {
    font = "Fira Mono",
    font_size = 18,
    -- the position the action list relative to, can be "screen" or "mouse"
    anchor = "screen",
    -- the corner to position reaper keys action list relative to
    -- Can be "C" (center), "T" (top), "R" (right), "B" (bottom), "L" (left), "TR" , "TL", "BR", or "BL"
    corner = "C",
    -- controls which commands are considered repeatable by specifying the action type it should contain in its action sequence
  },
  repeatable_commands_action_type_match = {
    'command',
    'operator',
    'meta_command',
  }
}

