local runner = require('command.runner')
local state_interface = require('state_machine.state_interface')
local config = require('definitions.config')

return {
  all_modes = {
    { { 'command' }, runner.runAction },
  },
  normal = {
    {
      { 'timeline_operator', 'timeline_selector' },
      function(timeline_operator, timeline_selector)
        local start_sel, end_sel = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
        runner.runAction(timeline_selector)
        runner.runAction(timeline_operator)

        if type(timeline_operator) ~= 'table' or not timeline_operator['setTimeSelection'] then
          reaper.GetSet_LoopTimeRange(true, false, start_sel, end_sel, false)
        end
      end
    },
    {
      { 'timeline_operator', 'timeline_motion' },
      function(timeline_operator, timeline_motion)
        local start_sel, end_sel = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
        runner.makeSelectionFromTimelineMotion(timeline_motion, 1)
        runner.runAction(timeline_operator)
        if type(timeline_operator) ~= 'table' or not timeline_operator['setTimeSelection'] then
          reaper.GetSet_LoopTimeRange(true, false, start_sel, end_sel, false)
        end
      end
    },
    { { 'timeline_motion' }, runner.runAction },
  },
  visual_timeline = {
    { { 'visual_timeline_command' }, runner.runAction },
    {
      { 'timeline_operator' },
      function(timeline_operator)
        runner.runAction(timeline_operator)
        state_interface.setModeToNormal()
        if not config.persist_visual_timeline_selection then
          runner.runAction("ClearTimeSelection")
        end
      end
    },
    { { 'timeline_selector' }, runner.runAction },
    {
      { 'timeline_motion' },
      function(timeline_motion)
        local args = {timeline_motion}
        local move_function = runner.runAction
        runner.extendTimelineSelection(move_function, args)
      end
    },
  }
}
