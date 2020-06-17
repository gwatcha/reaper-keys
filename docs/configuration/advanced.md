---
layout: default
title: Advanced Configuration
nav_order: 4
parent: Configuration
---

# Advanced Configuration
{: .no_toc}

1. TOC
{:toc}


## Action Sequences and Modes

### Relevant Files

    internal
    ├── command
    │   ├── action_sequence_functions
    │   │   ├── global.lua
    │   │   ├── main.lua
    │   │   └── midi.lua


### Configuration

If you are interested in changing or creating modes, action types, or action action sequences, take a look at `action_sequence_functions` directory.

There you will find all the functions that execute composed actions (excluding
meta actions). There is a file for each context, and a section for each mode.

Here is an example entry that defines the sequence `'timeline_operator'
timeline_motion'`, with the accompanying 'glue' function that composes the actions.

``` lua
-- in global.lua
normal = {
  {
    { 'timeline_operator', 'timeline_selector' },
    function(timeline_operator, timeline_selector)
      local start_sel, end_sel = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
      runner.runAction(timeline_selector)
      runner.runAction(timeline_operator)

      -- check if we were passed a table so we don't break when checking an option
      if type(timeline_operator) ~= 'table' or not timeline_operator['setTimeSelection'] then
        reaper.GetSet_LoopTimeRange(true, false, start_sel, end_sel, false)
      end
    end
  },
  -- ... more action sequence functions
```

When a key binding sequence triggers the action, it will be passed the values of
the actions used to trigger it.

So in this case, if one types `tl`

Reaper keys will find the entries "PlayAndLoop" and "NextBeat" in it's search in the definitions.

``` lua
-- in definitions/global.lua the
  timeline_operator = {
    ["t"] = "Play",
  },
  timeline_motion = {
    ["l"] = "NextBeat",
  },
```

And find the value of the action in actions.lua

``` lua
-- in definitions/actions.lua
PlayAndLoop = {"SetLoopSelectionToTimeSelection", "LoopStart", "TransportPlay", setTimeSelection=true},
NextBeat = 40841,
```

and execute the function with

``` lua
function({"SetLoopSelectionToTimeSelection", "LoopStart", "TransportPlay", setTimeSelection=true}, 40841)
```

Reaper keys prioritizes entries in order of  context, then index in the list.

It is enough to define an entry like the above, with a new action type or key
type sequence, to create a new action type.

To create a new mode, add an entry at the level of 'normal' in the example. Then
populate it with entries alike the above.


## Custom Actions

### Relevant Files

    internal
    ├── custom_actions
    │   ├── custom_actions.lua
    │   ├── movement.lua
    │   ├── selection.lua
    │   └── utils.lua

### Configuration

To create a custom action, follow the examples in the `custom_actions` directory. This directory contains all the actions available via the `custom` import in the `actions` file. 

`reaper` is a global which provides access too the [reaper api](https://www.reaper.fm/sdk/reascript/reascripthelp.html#l)


