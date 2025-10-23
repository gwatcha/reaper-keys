---
title: Action Composition
nav_order: 1
---

# Action Composition

The main feature reaper-keys provides is the ability to compose actions of different types to create new commands. 

How one can compose action types (i.e. the available _action sequences_) and their behaviour when joined is dependant on the [mode](modes) of reaper-keys. 

Take as an example the `timeline motion` type as well as the `timeline operator` type. In normal mode, any `timeline motion` may precede any `timeline operator`. When this action sequence is entered, it will result in the `timeline operator` being called on the timeline section between the cursor position before the motion and after the motion.

So one could enter <kbd>sL</kbd>, to create `(s = "SelectItems", L = "NextMeasure")`, and select the items up to the next measure.

There are various action types in reaper-keys.

## Action Types

| Action Type | Description |
| ------ | ---- |
| `command` | A generic command. Does not compose, accessible from every mode |
| `timeline motion` | Moves the edit cursor somewhere on the timeline |
| `timeline selector` | Sets the timeline selection  |
| `timeline operator` | Executes a command that operates on the timeline selection |
| `track motion` | Changes the last touched track |
| `track selector` | Selects a track or multiple tracks |
| `track operator` | Executes a command that operates on a track selection |
| `visual timeline command` | A command only available in visual timeline mode |
| `visual track command` | A command only available in visual track mode |


Check out the [modes](modes) documentation to learn about how these types compose together.


---
layout: default
title: Actions
nav_order: 2
parent: Configuration
---

# Actions

## Relevant Files

      ├── definitions
          ├── actions.lua
          └── defaults
              └── actions.lua


## Configuration

The `actions` file contains reaper-keys action definitions.

If a reaper-keys action does not exist for a reaper command you want to create a binding for, you may add an entry into this file. You just need to come up with a name for the action and get it's command id (available in reapers action list).

Here is an example entry that creates the reaper-keys action `SelectFoldersChildren` that contains the command id of the SWS command to select a folders children.

``` lua
SelectFoldersChildren = "_SWS_SELCHILDREN2",
```

Reaper-keys actions may also be a sequence of command id's, reaper-key
action names, provided 'lib' functions, provided 'custom' functions, or any combination of them. 

Here is a variety of action definitions that demonstrate this functionality.

``` lua
SelectOnlyCurrentTrack = custom.select.onlyCurrentTrack,
UnselectItems = 40289,
UnselectEnvelopePoints = 40331,
UnselectAllEvents = {40214, midiCommand=true},
ResetSelection = {"SelectOnlyCurrentTrack", "UnselectItems", "UnselectEnvelopePoints", "UnselectAllEvents"},
Stop = 40667,
SetModeNormal = lib.setModeNormal,
SetRecordModeNormal = 40252,
Reset = {"Stop", "SetModeNormal", "SetRecordModeNormal", "ResetSelection"},
```


## Action Options
You may have noticed that this action had an option set:
``` lua
UnselectAllEvents = {40214, midiCommand=true},
```

There are various other options one can use as well. 

| Option                | Use                                                                                                  |
| ------                | ---                                                                                                  |
| repetitions           | Specifies the number of times to run the action                                                      |
| prefixRepetitionCount | Indicates a number may prefix the actions key binding which will indicate repetitions.               |
| setTimeSelection      | Used with timeline operator actions to indicate it to keep the time selection it operated on, not restore the previous. |
| setTrackSelection     | Used with track operator actions to indicate it to keep the track selection it operated on, not restore the previous. |
| midiCommand           | Indicates that the action id is from Reaper's 'MidiEditor' section                                   |


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
PlayAndLoop = {"SetLoopSelectionToTimeSelection", "LoopStart", "Play", setTimeSelection=true},
NextBeat = 40841,
```

and execute the function with

``` lua
function({"SetLoopSelectionToTimeSelection", "LoopStart", "Play", setTimeSelection=true}, 40841)
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

`reaper` is a global which provides access to the [reaper api](https://www.reaper.fm/sdk/reascript/reascripthelp.html#l)




---
layout: default
title: Reaper-Keys Behaviour
nav_order: 3
parent: Configuration
---

# Reaper-Keys Behaviour

## Relevant Files

    ├── definitions
        └── config.lua
        
        
## Configuration

The `config` file has a table of options that tweaks reaper-keys behaviour.

| Option                                  | Values                                   | Use                                                                                                                     |
| ---                                     | ---                                      | ---                                                                                                                     |
| `log_level`                             | [trace debug info warn user error fatal] | sets log verbosity                                                                                                      |
| `persist_visual_timeline_selection`     | [true false]                             | controls if timeline operators in visual timeline mode reset the timeline selection                                     |
| `persist_visual_track_selection`        | [true false]                             | controls if track operators in visual track mode reset the track selection                                              |
| `allow_visual_track_timeline_movement`  | [true false]                             | controls if timeline movement in `visual track` mode is allowed                                                         |
| `repeatable_commands_action_type_match` | table of action type match strings       | controls which commands are considered repeatable by specifying the action type it should contain in its action sequence |


---
layout: default
title: Bindings
nav_order: 1
parent: Configuration
---

# Bindings

## Relevant Files

        
    ├── definitions
        ├── bindings.lua
        └── defaults
            ├── global.lua
            ├── main.lua
            └── midi.lua
        
        

## Configuration

```lua
-- add a binding by specifying a key sequence and an action name

-- remove a binding by specifying an action with no name
["<SPC>"] = "",

-- overwrite an entire folder by changing the name
["<SPC>"] = { "+new folder name", {
                ["<C-b>"] = "ShowBindingList"
}},

-- overwrite or add a binding in a folder by keeping the name the same
["<SPC>"] = { "+leader commannds", {
                ["<C-b>"] = "ShowBindingList"
                ["b"] = "",
}},
```

The `global`, `main`, and `midi` files contain default binding definitions (i.e. 'key sequence -> action' mappings)


You may define or change key sequences for a specific context (in `main` or `midi`) or for all contexts (in `global`).

The entries in these files are organized by `action type`.

Here is an example snippet that declares some bindings in the `timeline operator`
action type section.

```lua
timeline_operator = {
    ["r"] = "Record",
    ["t"] = "PlayAndLoop",
  },
```  

Actions may also be put into folders. To create a folder,  follow this format:

``` lua
command = {
  ["<SPC>"] = { "+leader commands", {
    ["<SPC>"] = "ShowBindingList",
    ["b"] = "ShowBindingList",
    ["m"] = { "+midi", {
                ["x"] = "CloseWindow",
                ["g"] = "SetMidiGridDivision",
                ["q"] = "Quantize",
                [","] = {"+options", {
                            ["g"] = "ToggleMidiEditorUsesMainGridDivision",
                            ["s"] = "ToggleMidiSnap",

                }},
    }},
}
``` 


---
title: Configuration
nav_order: 5
has_toc: true
has_children: true
---

# Configuration
For most configuration needs, check out the `definitions` directory. 

    ├── definitions
        ├── actions.lua
        ├── config.lua
        ├── global.lua
        ├── main.lua
        └── midi.lua
        
These files contain lua tables that may be altered to change or add key bindings, actions, or tweak reaper-keys behaviour. 

Read on to learn how to configure a particular aspect of reaper-keys.


Reaper-keys has multiple modes. Depending on the mode one is in, the available action sequences may change. The behaviour of action sequences may change as well.

The action sequence(s) available for all modes are:

| Action Sequence | Behaviour |
| --- | --- |
| `command` | Just executes the action |

## Normal  Mode

Return to normal mode via <kbd>ESC</kbd> by default.

### Available Action Sequences

| Action Sequence | Behaviour |
| ---| ---|
| `timeline motion`| Moves edit cursor to the motion end |
| `track motion` | Changes last touched track to the motion end |
| `timeline operator`->`timeline selector` | Executes the operator on the selection specified by the selector |
| `timeline operator`->`timeline motion`  | Executes the operator on the region between the start and end points of the motion |
| `track operator`->`track motion` | Executes the operator on the tracks between the start and end points of the motion |
| `track operator`->`track selector` | Executes the operator on the selection specified by the selector |


## Visual Timeline Mode

Enter this mode by via <kbd>v</kbd> by default.

In this mode, `timeline motion` and `timeline selection` action types extend or set the current timeline selection.

Also the `timeline operator` type does not require a `timeline motion` or `timeline selector` to come before, as in normal mode, and instead operates immediately
on the current timeline selection and then exits visual timeline mode.

It also allows for the execution of `visual track command` types.

### Available Action Sequences


| Action Sequence | Behaviour |
| --- | ---  |
| `timeline selector` | Sets the timeline selection  |
| `timeline motion` | Extends the timeline selection to the new edit cursor position  |
| `timeline operator` | Executes the operator and exits to normal mode. |
| `visual timeline command` | Executes a visual timeline command. |


## Visual Track Mode

Enter this mode by via <kbd>V</kbd> by default.

This mode is the same in principle as `visual timeline` mode, just with track motions/selections and track operators instead.

### Available Action Sequences

| Action Sequence | Behaviour |
| --- | --- |
| `track selector` | Sets the track selection  |
| `track motion` | Extends the track selection up to the new track position after the motion |
| `track operator` | Executes the operator and exits to normal mode. |
| `visual track command` | Executes a visual track command. |

