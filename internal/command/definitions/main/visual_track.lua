return {
  {
    { 'track_operator' },
    function(state, track_operator)
      return state
    end
  },
  {
    { 'track_motion' },
    function(state, track_motion)
      return state
    end
  },
  {
    { 'track_selector' },
    function(state, track_selector)
      return state
    end
  },
  {
    { 'number', 'track_motion' },
    function(state, number, track_motion)
      return state
    end
  },
  {
    { 'command' },
    function(state, action)
      return state
    end
  },
  {
    { 'number', 'command' },
    function(state, number, action)
      return state
    end
  },
}
