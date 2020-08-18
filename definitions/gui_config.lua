local os_default_fonts = {
  windows = "Lucida Console",
  osx = "Andale Mono",
  linux = "Fira Mono",
}

local os = reaper.GetOS()
local default_font = (os:match("Win") and os_default_fonts.windows)
  or (os:match("OSX") and os_default_fonts.osx)
  or os_default_fonts.linux

return {
  -- the factor to scale all gui elements (font size, element sizes...)
  -- will be multiplied by 2 if HiDPI mode is detected
  gui_scale = 1,
  action_type_colors = {
    command = {.4, 0.8, 0.5, 1},
    track_motion = {0.7, 0.51, 0.8, .8},
    track_selector = {0.85, 0.6, 0.8, 1},
    track_operator = {0.8, 0.51, 0.8, 1},
    visual_track_command = {0.65, 0.8, 0.8, 1},
    timeline_motion = {0.8, 0.6, 0.47, 1},
    timeline_selector = {0.85, 0.6, 0.47, 1},
    timeline_operator = {0.8, 0.51, 0.5, 1},
    visual_timeline_command = {0.7, 0.8, 0.58, 1},
  },
  feedback = {
    idle_time_until_show = 1,
    elements = {
      column_padding = 20,
      row_padding = 0,
      padding = 10,
      mode_line_h = 10,
    },
    fonts = {
      feedback_main = {default_font, 18},
      feedback_key = {default_font, 18},
      feedback_arrow = {default_font, 20},
      feedback_folder = {default_font, 18, "b"},
    },
    colors = {
      visual_timeline = {0.7, 0.8, 0.58, 1},
      extra_info = {1, 1, 1, .4},
      visual_track = {0.65, 0.8, 0.8, 1},
      key = {0.7, 0.51, 0.8, 1},
      arrow = {0.3, 0.51, 0.8, 1},
      folder = {0.6, 1, 0.85, .6},
    },
  },
  binding_list = {
    fonts = {
      binding_list_main = {default_font, 18},
      binding_list_label = {default_font, 14},
    },
    -- RGBA
    colors = {
      selection = {0.09, 0.26, 0.09, 1},
      count = {0.65, 0.8, 0.8, 1},
      query = {0.6, 1, 0.85, 1},
      action_name = {0.75, 0.75, 0.75, 1},
      matched_key = {.8, 0.3, 0.3, 1},
      bindings = {
        main = {0.81, 0.64, 0.79, 1},
        midi = {0.29, 0.74, 0.69, 1},
        global = {0.49, 0.65, 0.4, 1},
      }
    },
  }
}
