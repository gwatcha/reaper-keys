-- leave empty to use default font. Invalid fonts will be ignored silently
local font_name = ""

-- All colors are in RGBA format

return {
    -- the factor to scale all elements (font size, element sizes...)
    -- will be multiplied by 2 if HiDPI (MacOS Retina only) mode is detected
    gui_scale = 1.6,

    action_type_colors = {
        command = { .4, 0.8, 0.5, 1 },
        track_motion = { 0.7, 0.51, 0.8, .8 },
        track_selector = { 0.85, 0.6, 0.8, 1 },
        track_operator = { 0.8, 0.51, 0.8, 1 },
        visual_track_command = { 0.65, 0.8, 0.8, 1 },
        timeline_motion = { 0.8, 0.6, 0.47, 1 },
        timeline_selector = { 0.85, 0.6, 0.47, 1 },
        timeline_operator = { 0.8, 0.51, 0.5, 1 },
        visual_timeline_command = { 0.7, 0.8, 0.58, 1 },
    },

    feedback = {
        show_after = .1, -- seconds
        elements = {
            column_padding = 20,
            row_padding = 0,
            padding = 5,
            mode_line_h = 10,
        },
        fonts = {
            feedback_main = { font_name, 18 },
            feedback_key = { font_name, 18 },
            feedback_arrow = { font_name, 20 },
            feedback_folder = { font_name, 18, "b" },
        },
        colors = {
            visual_timeline = { 0.7, 0.8, 0.58, 1 },
            extra_info = { 1, 1, 1, .4 },
            visual_track = { 0.65, 0.8, 0.8, 1 },
            key = { 0.7, 0.51, 0.8, 1 },
            arrow = { 0.3, 0.51, 0.8, 1 },
            folder = { 0.6, 1, 0.85, .6 },
        },
    },
    binding_list = {
        fonts = {
            binding_list_main = { font_name, 18 },
            binding_list_label = { font_name, 14 },
        },
        colors = {
            selection = { 0.09, 0.26, 0.09, 1 },
            count = { 0.65, 0.8, 0.8, 1 },
            query = { 0.6, 1, 0.85, 1 },
            action_name = { 0.75, 0.75, 0.75, 1 },
            matched_key = { .8, 0.3, 0.3, 1 },
            bindings = {
                main = { 0.81, 0.64, 0.79, 1 },
                midi = { 0.29, 0.74, 0.69, 1 },
                global = { 0.49, 0.65, 0.4, 1 },
            }
        },
    }
}
