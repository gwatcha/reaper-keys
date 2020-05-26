
# Table of Contents

1.  [Reaper-Keys](#org2d2e474)
    1.  [Pros](#orgce92733)
    2.  [Features](#org201ca46)
        1.  [Bind key sequences](#orgf7d111f)
        2.  [Compose actions](#org7ed8b3c)
        3.  [Multi-modal](#org12ab66a)
        4.  [Macros](#org9cae087)
    3.  [Installation](#org1c3b4a3)
    4.  [Help](#orgf08f4b7)
    5.  [Configuration](#orgb56d37f)


<a id="org2d2e474"></a>

# Reaper-Keys

Reaper-Keys is an extension for the [REAPER DAW](https://www.reaper.fm/), that provides a new action
mapping system based on key sequences instead of key chords. The system is 
similar to [Vim](https://en.wikipedia.org/wiki/Vim_%28text_editor%29), a modal text editor, and by default comes with vim-like bindings. 


<a id="orgce92733"></a>

## Pros

-   Saving a couple minutes per hour
-   Developing arthritis at 60 instead of 40
-   Reduced mouse usage
-   A more fluid experience
-   Quick access to many key bindings


<a id="org201ca46"></a>

## Features


<a id="orgf7d111f"></a>

### Bind key sequences

With reaper-keys, you may bind key sequences to actions, rather then singular
key presses. This allows one to make use of mnemonics, such as 't' for track,
or 'a' for arming.

A completion/feedback window is provided to assist with command completion. Here
is an example of navigating through the menu to render a project.

![img](img/save.gif)


<a id="org7ed8b3c"></a>

### Compose actions

Reaper-keys  lets one compose actions of different types to create new commands.
For example, any `timeline motion`  action can follow any  `timeline operator`
action, and any `number` can prefix a `timeline motion`.

If one enters `c2L` it would compose into `(c = "Change", 2, L = "NextMeasure")`,
and trigger a command to set up a record loop and record over the next 2 measures.

![img](img/change.gif)

To select the items in the next 2  measures, one could enter `s2L`.

![img](img/select.gif)

This grows the number of available actions exponentially but still preserves your
brain, as you only need to know the `timeline_motions`, `timeline_operators`, and
the fact that you can compose them. 


<a id="org12ab66a"></a>

### Multi-modal

Changing modes changes the way keys compose. By default, it is in `normal` mode, but you could for example go into `visual timeline` mode by pressing `v`.

In this mode, `timeline motions` extend the current time selection, and `timeline
actions` operate immediately and return one to `normal` mode. Useful if you want
visual feedback before executing a timeline action, or just want to extend the
time selection using motion commands.

![img](img/mode.gif)


<a id="org9cae087"></a>

### Macros

Macros are a way to save a sequence of commands, and play them back later.

To record a macro, enter `q` and an arbitrary character to specify the `register` that
the macro will save into. Then, perform a series of actions, and finish
recording by pressing `q`. 

![img](img/rec_macro.gif)

You may play it back by entering `@` and the character you specified earlier.
Optionally, prefix it with a number to indicate the number of repetitions.

![img](img/play_macro.gif)

Here is an example of recording and playing a macro that deletes item parts across
two tracks in a ribbon style.


<a id="org1c3b4a3"></a>

## Installation

-   Clone this repository or download it via the 'releases' tab.
-   Put this repository into your  `REAPER/Scripts`  directory . If you're unsure where your `REAPER` directory is, just run the action 'Show REAPER resource path in explorer' in REAPER.
-   Back up your key map by exporting it, then import the provided keymap `reaper-keys.ReaperKeyMap` via the `import` button at the bottom of the action list window in Reaper. (This will overwrite your current key bindings!)
-   For all the actions to work, install the [SWS/S&M](https://sws-extension.org/)  extension for Reaper .


<a id="orgf08f4b7"></a>

## Help

Enter `<SPC>h` to print a list of available bindings, their action types, as well as the available
action sequences for the current context and mode.


<a id="orgb56d37f"></a>

## Configuration

All you need to configure reaper-keys is under the <definitions/> directory.  
Take a look at the <definitions/README.md> file for more details.

