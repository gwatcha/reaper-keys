
# Table of Contents

1.  [Reaper-Keys](#orge58639d)
    1.  [Pros](#org2c06f6e)
2.  [Features](#org09782b4)
    1.  [Bind key sequences](#org3b1143c)
    2.  [Compose actions](#orgcf979d4)
    3.  [Multi-modal](#org6a74606)
    4.  [Macros](#org13832dc)
    5.  [Hint Box](#orgd24792f)
3.  [Installation](#org87f2ab8)
4.  [Configuration](#org0204f84)
5.  [Future Plans](#orgf64632a)


<a id="orge58639d"></a>

# Reaper-Keys

Reaper-Keys is an extension for the [REAPER DAW](https://www.reaper.fm/), that provides a new action
mapping system based on key sequences instead of key chords. The system is 
very similar to [Vim](https://en.wikipedia.org/wiki/Vim_%28text_editor%29), a modal text editor, and by default comes with vim-like bindings. 

Reaper-keys provides features like composable actions, macros, multiple edit
modes and more.


<a id="org2c06f6e"></a>

## Pros

-   Saving a couple minutes per hour
-   Developing arthritis at 60 instead of 40
-   Reduced mouse usage
-   A more fluid experience


<a id="org09782b4"></a>

# Features


<a id="org3b1143c"></a>

## Bind key sequences

With reaper-keys, you may bind key sequences to actions, rather then singular
key presses. This allows one to make use of mnemonics, such as 't' for track,
or 'a' for arming.

A completion/feedback window is provided to assist with command completion. Here
is an example of navigating through the menu to render a project.

[completions](img/completion.gif)


<a id="orgcf979d4"></a>

## Compose actions

Reaper-keys  lets one compose actions of different types to create new commands.
For example, any `timeline motion`  action can follow any  `timeline operator`
action, and any `number` can prefix a `timeline motion`.

If one enters `c4l` it would compose into `(c = "Change", 4, l = "NextBeat")`, and trigger a command to set up a record loop to change the next 4 beats.

&#x2026; video &#x2026;

To select the items in the next 4 beats , one could enter `s4l`.

This grows the number of available actions exponentially but still preserves your
brain, as you only need to know the `timeline_motions`, `timeline_operators`, and
the fact that you can compose them. 


<a id="org6a74606"></a>

## Multi-modal

Changing modes changes the way keys compose. By default, it is in `normal` mode, but you could for example go into `visual timeline` mode by pressing `v`.

In this mode, `timeline motions` extend the current time selection, and `timeline
actions` operate immediately and return one to `normal` mode. Useful if you want
visual feedback before executing a timeline action, or just want to extend the
time selection using motion commands.

.. video ..


<a id="org13832dc"></a>

## Macros

Macros are a way to save a sequence of commands, and play them back later.

To record a macro, enter `q` and an arbitrary character to specify the `register` that
the macro will save into. Then, perform a series of actions, and finish
recording by pressing `q`. 

You can play it back by entering `@` and the character you specified earlier.

Here is an example of recording a macro that deletes every second note for a midi track.

.. video ..


<a id="orgd24792f"></a>

## Hint Box

A hint box with autocompletions and feedback.

.. video ..


<a id="org87f2ab8"></a>

# Installation

-   Clone this repository or download it via the 'releases' tab.
-   Put this repository into your  `REAPER/Scripts`  directory . If you're unsure where your `REAPER` directory is, just run the action 'Show REAPER resource path in explorer' in REAPER.
-   Back up your key map by exporting it, then import the provided keymap `reaper-keys.ReaperKeyMap` via the `import` button at the bottom of the action list window in Reaper. (This will overwrite your current key bindings!)
-   For all the actions to work, install the [SWS/S&M](https://sws-extension.org/)  extension for Reaper .


<a id="org0204f84"></a>

# Configuration

All you need to configure reaper-keys is under the `definitions` directory.  
Take a look at the `definitions/README` file for more details.


<a id="orgf64632a"></a>

# Future Plans

-   A GUI for adding new key bindings.
-   A GUI for the help window.
-   Registers for storing and retrieving all sorts of things such as fx chains,
    track selections, items, snapshots.

