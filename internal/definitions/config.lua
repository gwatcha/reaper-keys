return {
    show_start_up_message = false, -- TODO should be true by default
    show_feedback_window = true,
    dock_feedback_window = true,
    profile = false,
    -- should operators in visual modes reset the selection or have it persist?
    persist_visual_timeline_selection = true,
    persist_visual_track_selection = false,
    allow_timeline_movement_in_visual_mode = true,
    log_level = 'error', -- trace debug info warn user error fatal
    repeatable_commands_action_type_match = { -- TODO ?
        'command',
        'operator',
        'meta_command',
    }
}
