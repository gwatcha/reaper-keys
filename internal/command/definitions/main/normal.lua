return {
  {
    { 'track_operator', 'track_selector' },
    function(state, track_operator, track_selector)
      return state
    end
  },
  {
    { 'track_operator', 'number', 'track_motion' },
    function(state, track_operator, number, track_motion)
      return state
    end
  },
  {
    { 'track_operator', 'track_motion' },
    function(state, track_operator, number, track_motion)
      return state
    end
  },
}
