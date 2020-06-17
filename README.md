# Reaper-Keys

<p align="center">
  <img src="img/reaper-keys.png">
</p>

Reaper-Keys is an extension for the [REAPER DAW](https://www.reaper.fm/), that provides a new action
mapping system based on key sequences instead of key chords. The system is
similar to [Vim](https://en.wikipedia.org/wiki/Vim_%28text_editor%29), a modal text editor, and by default comes with vim-like bindings.

Click [here](https://youtu.be/ChuZswEfQuo) for a demo video.


<a id="orgbaedca2"></a>

## Pros

- Saving a couple minutes per hour
- Developing arthritis at 60 instead of 40
- Ability to reduce mouse usage
- Increased maximum bandwidth between your brain and the track your mixing

<a id="orga772014"></a>

# Table of Contents

1.  [Reaper-Keys](#org3c1380e)
    1.  [Pros](#orgbaedca2)
    2.  [Features](#orga772014)
        1.  [Bind key sequences](#orgba6e7da)
        2.  [Compose actions](#org43150a4)
        3.  [Multi-modal](#org67ec5f9)
        4.  [Macros](#org00bfab6)
    3.  [Installation](#orgc80dfd9)
    4.  [Help](#org08b4794)
    5.  [Configuration](#org1ecda81)

<a id="org3c1380e"></a>

## Features

<a id="orgba6e7da"></a>

### Bind key sequences

With reaper-keys, you may bind key sequences to actions, rather then singular
key presses. This allows one to make use of mnemonics, such as 't' for track,
or 'a' for arming.

A completion/feedback window is provided to assist with command completion. Here
is an example of navigating through the menu to render a project.

![img](img/save.gif)

<a id="org43150a4"></a>

### Compose actions

Reaper-keys lets one compose actions of different types to create new commands.

For example, in normal mode, any action with `timeline motion` type can follow any one with `timeline operator` type. Also, most `timeline motion` types allow one to prefix a number to indicate repetitions.

So if one enters `c2L` it would compose into `(c = "Change", L = [2, "NextMeasure"])`,
and trigger a command to set up a record loop and record over the next 2 measures.

![img](img/change.gif)

To select the items in the next 2 measures, one could enter `s2L`.

![img](img/select.gif)

This grows the number of available actions exponentially but still preserves your
brain, as you only need to know the `timeline_motions`, `timeline_operators`, and
the fact that you can compose them.

<a id="org67ec5f9"></a>

### Multi-modal

Changing modes changes the way keys compose. By default, it is in `normal` mode, but you could for example go into `visual timeline` mode by pressing `v`.

In this mode, `timeline motions` extend the current time selection, and `timeline actions` operate immediately and return one to `normal` mode. Useful if you want
visual feedback before executing a timeline action, or just want to extend the
time selection using motion commands.

![img](img/mode.gif)

<a id="org00bfab6"></a>

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

<a id="orgc80dfd9"></a>

## Installation

- Clone this repository or download it via the 'releases' tab (download the file 'reaper-keys.zip').
- Put this repository into your `REAPER/Scripts` directory . If you're unsure where your `REAPER` directory is, just run the action 'Show REAPER resource path in explorer' in REAPER.
- Back up your key map by exporting it, then import the provided keymap `reaper-keys.ReaperKeyMap` via the `import` button at the bottom of the action list window in Reaper. (This will overwrite your current key bindings!)
- For all the actions to work, install the [SWS/S&M](https://sws-extension.org/) extension for Reaper.

When you want to restore your old keymap, you must empty the `reaper-kb.ini` in your `REAPER` root directory and restart REAPER. Otherwise, there will likely be remnants from reaper-keys. 


**Important Update:**

There was a bug with windows and osx path names that has been fixed since Wednesday, May 27th. If you downloaded the library before then, you will need to update it!
Follow the instructions for reverting your keymap, and just reimport the updated one. Just be sure you delete the `REAPER/reaper-kb.ini` file.


<a id="org08b4794"></a>

## Help

Enter `<SPC>h` to print a list of available bindings, their action types, as well as the available
action sequences for the current context and mode.

If your stuck in a state you don't know how to get out of, you can press `<ESC>` to reset back to normal.

<a id="org1ecda81"></a>


## Further Information

Check out the [documentation](https://gwatcha.github.io/reaper-keys) to learn more.
