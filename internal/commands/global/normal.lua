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
          return state
        end
      },
      {
        { 'timeline_operator', 'timeline_motion' },
        function(state, timeline_operator, timeline_motion)
          return state
        end
      },
      {
        { 'timeline_operator', 'number', 'timeline_motion' },
        function(state, timeline_operator, number, timeline_motion)
          return state
        end
      },
      {
        { 'timeline_motion' },
        function(state, timeline_motion)
          return state
        end
      },
      {
        { 'number', 'timeline_motion' },
        function(state, number, timeline_motion)
          return state
        end
      },
      {
        { 'action' },
        function(state, action)
          return state
        end
      },
      {
        { 'number', 'action' },
        function(state, number, action)
          return state
        end
      },
  }
