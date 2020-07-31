return {
  -- the factor to scale all gui elements (font size, element sizes...) 
  -- will be multiplied by 2 if HiDPI mode is detected
  gui_scale = 1,
  action_list = {
    main_font = {"Fira Mono", 18},
    aux_font = {"Liberation Mono", 14, "bi"},
    seperator_size = 30,
    -- RGBA
    colors = {
      action_type = {
        command = {.4, 0.8, 0.5, 1},
        track_motion = {0.7, 0.51, 0.8, .8},
        track_selector = {0.85, 0.6, 0.8, 1},
        track_operator = {0.8, 0.51, 0.8, 1},
        visual_track_command = {0.65, 0.8, 0.8, 1},
        timeline_motion = {0.7, 0.51, 0.47, .8},
        timeline_selector = {0.85, 0.6, 0.47, 1},
        timeline_operator = {0.8, 0.51, 0.5, 1},
        visual_timeline_command = {0.7, 0.8, 0.58, 1},
      },
      selection = {0.09, 0.26, 0.09, 1},
      query = {0.6, 1, 0.85, 1},
      action_name = {0.75, 0.75, 0.75, 1},
      matched_key = {.8, 0.3, 0.3, 1},
      main_binding = {0.81, 0.64, 0.79, 1},
      midi_binding = {0.29, 0.74, 0.69, 1},
      global_binding = {0.49, 0.7, 0.49, 1},
    },
    -- the position the action list relative to, can be "screen" or "mouse"
    anchor = "screen",
    -- the corner to position reaper keys action list relative to
    -- Can be "C" (center), "T" (top), "R" (right), "B" (bottom), "L" (left), "TR" , "TL", "BR", or "BL"
    corner = "C",
    -- controls which commands are considered repeatable by specifying the action type it should contain in its action sequence
  }
}
