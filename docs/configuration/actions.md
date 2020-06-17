---
layout: default
title: Actions
nav_order: 2
parent: Configuration
---

# Actions

## Relevant Files

    ├── definitions
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

