local cmd = require('command.output')

return {
    {
      { 'macro_play', 'register_location' },
      function(state, macro_play, register_location)
        return state
      end
    },
    {
      { 'macro_rec', 'register_location' },
      function(state, macro_rec, register_location)
        return state
      end
    },
    {
      { 'register_key', 'register_location', 'register_action' },
      function(state, register_key, register_location, register_action)
        return state
      end
    },
    {
      { 'timeline_operator', 'timeline_selector' },
      function(state, timeline_operator, timeline_selector)
        cmd.runReaperCommand(timeline_selector)
        cmd.runReaperCommand(timeline_operator)
        return state
      end
    },
    {
      { 'timeline_operator', 'timeline_motion' },
      function(state, timeline_operator, timeline_motion)
        local sel_start = reaper.GetCursorPosition()
        cmd.runReaperCommand(timeline_motion)
        local sel_end = reaper.GetCursorPosition()

        cmd.makeSelectionFromPositions(sel_start, sel_end)
        cmd.runReaperCommand(timeline_operator)

        return state
      end
    },
    {
      { 'timeline_operator', 'number', 'timeline_motion' },
      function(state, timeline_operator, number, timeline_motion)
        local sel_start = reaper.GetCursorPosition()
        cmd.runReaperCommandNTimes(timeline_motion, number)
        local sel_end = reaper.GetCursorPosition()

        cmd.makeSelectionFromPositions(sel_start, sel_end)
        cmd.runReaperCommand(timeline_operator)

        return state
      end
    },
    {
      { 'timeline_motion' },
      function(state, timeline_motion)
        cmd.runReaperCommand(timeline_motion)
        return state
      end
    },
    {
      { 'number', 'timeline_motion' },
      function(state, number, timeline_motion)
        cmd.runReaperCommandNTimes(timeline_motion, number)
        return state
      end
    },
    {
      { 'action' },
      function(state, action)
        cmd.runReaperCommand(action)
        return state
      end
    },
    {
      { 'number', 'action' },
      function(state, number, action)
        cmd.runReaperCommandNTimes(action, number)
        return state
      end
    },
}
