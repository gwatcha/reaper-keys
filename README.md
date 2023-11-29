# Reaper-Keys

<p align="center">
  <img src="img/reaper-keys.png">
</p>

Reaper-Keys is an extension for the [REAPER DAW](https://www.reaper.fm/), that provides a new action
mapping system based on key sequences instead of key chords. The system is
similar to [Vim](https://en.wikipedia.org/wiki/Vim_%28text_editor%29), a modal text editor, and by default comes with vim-like bindings.

Click [here](https://youtu.be/ChuZswEfQuo) for a very outdated and low quality demo and installation video.

## Pros

- Save a couple minutes per hour
- Develop arthritis at 60 instead of 40
- Reduce mouse usage
- Increase maximum bandwidth between your brain and your project
- A structure for Reaper's giant bag of actions

# Table of Contents

* [Installation](#Installation)
* [Features](#Features)
    * [Bind key sequences](#Bind-key-sequences)
    * [Compose actions](#Compose-actions)
    * [Multi-modal](#Multi-modal)
    * [Macros](#Macros)
* [Help](#Help)
* [Further Information](#Further-Information)

## Installation

- Install [SWS/S&M](https://sws-extension.org/).
- Add this repository `TODO` in Reapack.

## Features

### Bind key sequences

With reaper-keys, you may bind key sequences to actions, rather then singular
key presses. This allows one to hierarchically organize many keybindings for easy access to many keybindings.

A completion/feedback window is provided to assist with command completion. 

![img](img/completions.gif)

### Compose actions

Reaper-keys lets one compose actions of different types to create new commands.

For example, in normal mode, any action with `timeline motion` type can follow any one with `timeline operator` type.

So if one enters `tL`, it would compose into `(t -> "PlayAndLoop", L -> "NextMeasure")`, and play and loop the next measure.

Other example `timeline operator` bindings are `s` -> "SelectItemsAndSplit" , or `z` -> "ZoomTimeSelection", so you could also enter `sL` or `zL`.

![img](img/compose.gif)

This grows the number of available actions exponentially but still preserves your
brain, as you only need to know the `timeline_motions`, `timeline_operators`, and
the fact that you can compose them.

### Multi-modal

Changing modes changes the way keys compose. By default, it is in `normal` mode, but you could for example go into `visual timeline` mode by pressing `v`.

In this mode, `timeline motions` extend the current time selection, and `timeline actions` operate immediately and return one to `normal` mode. Useful if you want
visual feedback before executing a timeline action, or just want to extend the
time selection using motion commands.

![img](img/visual_mode.gif)

### Macros

Macros are a way to save a sequence of commands, and play them back later.

To record a macro, enter `q` and an arbitrary character to specify the `register` that
the macro will save into. Then, perform a series of actions, and finish
recording by pressing `q`.

![img](img/macro_rec.gif)

You may play it back by entering `@` and the character you specified earlier.
Optionally, prefix it with a number to indicate the number of repetitions.

![img](img/macro_play.gif)

## Help

Enter `<M-x> (Alt + x)` to show a list of available bindings you can search and filter.

![img](img/binding_list.gif)

If you're stuck in a state you don't know how to get out of, you can press `<ESC>` to reset back to normal.

Also,
If your key press is not being detected, try unfocusing the feedback window.

## Further Information

Check out the [documentation](https://gwatcha.github.io/reaper-keys) to learn more.
