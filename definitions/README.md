
# Table of Contents

1.  [Configuration](#org5964e2a)
    1.  [Key sequences / Bindings](#orga280418)
    2.  [Action Types](#org514f859)
    3.  [Key Sequences](#org75c1f70)
        1.  [All Modes](#org534ffad)
        2.  [Normal  Mode](#orgb46f6ae)
        3.  [Visual Timeline Mode](#org4d78eea)
        4.  [Visual Track](#org9418a0e)
    4.  [Actions](#orga214d7e)
    5.  [Advanced Configuration](#orgaffcd37)


<a id="org5964e2a"></a>

# Configuration


<a id="orga280418"></a>

## Key sequences / Bindings

You may define or change key sequences for a specific context (in <main.lua> or <midi.lua>) or for all contexts (in <global.lua>).

I organize the entries in these files by `action type`.

Here is an example snippet that declares some bindings in the `timeline_operators`
action type section.

    timeline_operator = {
      ["c"] = "Change",
      ["t"] = "PlayAndLoop",
      ["d"] = "CutItems",
      ["y"] = "CopyItems",
    },

Actions may also be put into folders. To create a folder,  follow this format:

    ["<C-c>"] = "ToggleFloatingWindows",
    ["<SPC>"] = { "+leader commands", {
      ["<SPC>"] = "ShowActionList",
      ["h"] = "ShowReaperKeysHelp",
      ["r"] = {"+regions", {
                  ["d"] = "RemoveRegion",
      }},
    }}, -- be sure to close the folder


<a id="org514f859"></a>

## Action Types

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">action type</th>
<th scope="col" class="org-left">description</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">`command`</td>
<td class="org-left">A generic command. Does not compose, accessible from every mode.</td>
</tr>


<tr>
<td class="org-left">`timeline_motion`</td>
<td class="org-left">Moves the edit cursor somewhere on the timeline.</td>
</tr>


<tr>
<td class="org-left">`timeline_selector`</td>
<td class="org-left">Sets the timeline selection .</td>
</tr>


<tr>
<td class="org-left">`timeline_operator`</td>
<td class="org-left">An actions that operates on a timeline selection.</td>
</tr>


<tr>
<td class="org-left">`track_motion`</td>
<td class="org-left">Changes the selected track.</td>
</tr>


<tr>
<td class="org-left">`track_selector`</td>
<td class="org-left">Selects a track or multiple tracks.</td>
</tr>


<tr>
<td class="org-left">`track_operator`</td>
<td class="org-left">An actions that operaes on a selection of tracks.</td>
</tr>


<tr>
<td class="org-left">`visual_timeline_command`</td>
<td class="org-left">A command only available in visual timeline mode.</td>
</tr>


<tr>
<td class="org-left">`visual_track_command`</td>
<td class="org-left">A command only available in visual track mode</td>
</tr>


<tr>
<td class="org-left">`meta_command`</td>
<td class="org-left">A special command handled by the reaper-keys engine.</td>
</tr>
</tbody>
</table>


<a id="org75c1f70"></a>

## Key Sequences

In which ways you may compose keys (i.e. the available key sequences) depends on the mode of reaper-keys.
Listed below are the valid action sequences in each mode.


<a id="org534ffad"></a>

### All Modes

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />
</colgroup>
<tbody>
<tr>
<td class="org-left">`command`</td>
</tr>


<tr>
<td class="org-left">`number`, `command`</td>
</tr>


<tr>
<td class="org-left">`timeline_operator`, `timeline_selector`</td>
</tr>


<tr>
<td class="org-left">`track_motion`</td>
</tr>


<tr>
<td class="org-left">`number`, `track_motion`</td>
</tr>
</tbody>
</table>


<a id="orgb46f6ae"></a>

### Normal  Mode

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />
</colgroup>
<tbody>
<tr>
<td class="org-left">`timeline_operator`, `timeline_selector`</td>
</tr>


<tr>
<td class="org-left">`timeline_operator`, `timeline_motion`</td>
</tr>


<tr>
<td class="org-left">`timeline_operator`, `number`, `timeline_motion`</td>
</tr>


<tr>
<td class="org-left">`timeline_motion`</td>
</tr>


<tr>
<td class="org-left">`number`, `timeline_motion`</td>
</tr>


<tr>
<td class="org-left">`track_operator`, `track_motion`</td>
</tr>


<tr>
<td class="org-left">`track_operator`, `number`, `track_motion`</td>
</tr>


<tr>
<td class="org-left">`track_operator`, `track_selector`</td>
</tr>
</tbody>
</table>

*return to normal mode via '<ESC'> by default*


<a id="org4d78eea"></a>

### Visual Timeline Mode

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />
</colgroup>
<tbody>
<tr>
<td class="org-left">`visual_timeline_command`</td>
</tr>


<tr>
<td class="org-left">`timeline_operator`</td>
</tr>


<tr>
<td class="org-left">`timeline_selector`</td>
</tr>


<tr>
<td class="org-left">`timeline_motion`</td>
</tr>


<tr>
<td class="org-left">`number`, `timeline_motion`</td>
</tr>


<tr>
<td class="org-left">`track_selector`</td>
</tr>
</tbody>
</table>

*enter this mode by via 'v' by default.*


<a id="org9418a0e"></a>

### Visual Track

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />
</colgroup>
<tbody>
<tr>
<td class="org-left">`track_operator`</td>
</tr>


<tr>
<td class="org-left">`track_selector`</td>
</tr>


<tr>
<td class="org-left">`timeline_operator`</td>
</tr>


<tr>
<td class="org-left">`track_motion`</td>
</tr>


<tr>
<td class="org-left">`number`, `track_motion`</td>
</tr>
</tbody>
</table>

*enter this mode via 'V' by default*


<a id="orga214d7e"></a>

## Actions

The available actions for bindings are in the <actions.lua> file.

If an action does not exist for a command you want to create a binding for, you
may add an entry into <actions.lua> You just need to come up with a name for the
action and get it's `Command Id` ( available in reapers action list).

Here is an example entry:

    SelectFoldersChildren = "_SWS_SELCHILDREN2",

Reaper-keys actions may also be a sequence of command id's, reaper-key
action names, internal 'lib' or 'util' functions, or any combination of them. They may
also have additional options. So

Here is an example of a more complicated action definition, that makes use of
previous ones, and makes use of the repetitions option.

    Stop = 40667,
    SetModeNormal = lib.setModeToNormal,
    Reset = {"Stop", "SetModeNormal"},
    Reset4TimesAndPlayForSomeReason = {{"Reset", repetitions=4}, "TransportPlay"}

The available options are:

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">option</th>
<th scope="col" class="org-left">use</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">repetitions</td>
<td class="org-left">specifies the number of times to run the action</td>
</tr>


<tr>
<td class="org-left">midiCommand</td>
<td class="org-left">indicates that the action id is from REAPERs 'MidiEditor' section</td>
</tr>


<tr>
<td class="org-left">setTimeSelection</td>
<td class="org-left">used with timeline operator actions to set the timeline selection to the preceding movement/selector</td>
</tr>


<tr>
<td class="org-left">setTrackSelection</td>
<td class="org-left">used with track operator actions to keep the preceding track movement/selector selection</td>
</tr>
</tbody>
</table>


<a id="orgaffcd37"></a>

## Advanced Configuration

If you are interested in adding another mode or action type to reaper keys and
aren't scared of a bit of lua scripting, take a look at [sequence functions](file:///../internal/command/sequence_functions/) directory.

There you will find all the functions that execute composed actions (excluding
meta actions). There is a file for each context, and a section for each mode.

Here is an example entry that defines the sequence `'timeline_operator'
timeline_motion'`, with the accompanying 'glue' function that composes the actions.

    -- in global.lua
      normal = {
        {
          { 'timeline_operator', 'timeline_motion' },
          function(timeline_operator, timeline_motion)
            -- check out this link for the reaper api definitions
            -- https://www.reaper.fm/sdk/reascript/reascripthelp.html
            -- this gets the current time selection
            local start_sel, end_sel = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
            -- runner provides utility functions to execute actions, and do other things
            runner.makeSelectionFromTimelineMotion(timeline_motion, 1)
            runner.runAction(timeline_operator)
            -- check if we were passed a table so we don't break when checking an option
            if type(timeline_operator) ~= 'table' or not timeline_operator['setTimeSelection'] then
              -- revert the time selection because we were not specified not to
              reaper.GetSet_LoopTimeRange(true, false, start_sel, end_sel, false)
            end
          end
        },
        -- ...
      },

When a key binding sequence triggers the action, it will be passed the values of
the actions used to trigger it.

So in this case, if one types `tl`

Reaper keys will find the entries "PlayAndLoop" and "NextBeat" in it's search in the definitions.

    -- in definitoins/global.lua the
      timeline_operator = {
        ["t"] = "Play",
      },
      timeline_motion = {
        ["l"] = "NextBeat",
      },

And find the value of the action in actions.lua

    -- in definitions/actions.lua
    PlayAndLoop = {"SetLoopSelectionToTimeSelection", "LoopStart", "TransportPlay", setTimeSelection=true},
    NextBeat = 40841,

and execute the function with

    function({"SetLoopSelectionToTimeSelection", "LoopStart", "TransportPlay", setTimeSelection=true}, 40841)

Reaper keys prioritizes entries in order of  context, then index in the list.

It is enough to define an entry like the above, with a new action type or key
type sequence, to create a new action type.

To create a new mode, add an entry at the level of 'normal' in the example. Then
populate it with entries alike the above.

