{
  global = {
    normal = {
      { 'macro_play', 'register_location' },
      { 'macro_rec', 'register_location' },
      { 'register_key', 'register_location', 'register_action' },
      { 'timeline_operator', 'timeline_selector' },
      { 'timeline_operator', 'timeline_motion' },
      { 'timeline_operator', 'number', 'timeline_motion' },
      { 'timeline_motion' },
      { 'number', 'timeline_motion' },
      { 'action' },
      { 'number', 'action' },
    },
    visual_timeline = {
      { 'timeline_operator' },
      { 'timeline_motion' },
      { 'number', 'timeline_motion' },
      { 'action' },
      { 'number', 'action' },
    }
  },
  main = {
    normal = {
      { 'track_operator', 'track_selector' },
      { 'track_operator', 'number', 'track_motion' },
    },
    visual_track = {
      { 'track_operator' },
      { 'track_motion' },
      { 'track_selector' },
      { 'number', 'track_motion' },
      { 'action' },
      { 'number', 'action' },
    },
  },
  midi = {},
}
