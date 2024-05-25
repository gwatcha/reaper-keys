# Reaper keys

<p align="center"><img src="https://i.ibb.co/QHrVqNK/reaper-keys.png" alt="reaper-keys" border="0" /></p>

Reaper keys is an extension for the [REAPER DAW](https://www.reaper.fm/) that provides a
new action mapping system based on key sequences instead of key chords. The system is
similar to [Vim](https://en.wikipedia.org/wiki/Vim_%28text_editor%29), a modal text
editor, and by default comes with vim-like bindings.

Click [here](https://youtu.be/ChuZswEfQuo) for a very outdated and low quality demo for v1 or jump
to [examples](#some-ideas-to-start-with).

## Pros

- Save a couple minutes per hour
- Develop arthritis at 60 instead of 40
- Reduce mouse usage
- Increase maximum bandwidth between your brain and your project
- A structure for Reaper's giant bag of actions

## Installation

- Add `https://raw.githubusercontent.com/gwatcha/reaper-keys/master/index.xml` to Reapack.
- Optionally, install [SWS](https://sws-extension.org/) (by hand or from ReaTeam
  Extensions). Although this extension _may_ work without SWS, the experience will be
  worse.

## Features
### Bind key sequences

With Reaper keys you may bind key sequences to actions rather then singular key presses.
This allows one to hierarchically organize many keybindings.
A completion/feedback window is provided to assist with command completion.

<a href="https://ibb.co/N3fgVYP"><img src="https://i.ibb.co/N3fgVYP/completions.gif" alt="completions" border="0" /></a>

### Compose actions

Reaper keys lets one compose actions of different types to create new commands. For
example, in normal mode, any action with `timeline motion` type can follow any one with
`timeline operator` type. So if one enters `tL`, it would compose into `(t ->
"PlayAndLoop", L -> "NextMeasure")`, and play and loop the next measure.

Other examples of `timeline operator` bindings are `s` -> "SelectItemsAndSplit" , or `z`
-> "ZoomTimeSelection", so you could also enter `sL` or `zL`.

<a href="https://ibb.co/j8QfT0c"><img src="https://i.ibb.co/j8QfT0c/compose.gif" alt="compose" border="0" /></a>

This grows the number of available actions exponentially but still preserves your brain,
as you only need to know the `timeline_motions`, `timeline_operators`, and the fact that
you can compose them.

### Multi-modal

Changing modes changes the way keys compose. By default, it is in `normal` mode, but you
could for example go into `visual timeline` mode by pressing `v`.

In this mode, `timeline motions` extend the current time selection, and `timeline actions`
operate immediately and return one to `normal` mode. Useful if you want visual feedback
before executing a timeline action, or just want to extend the time selection using motion
commands.

<a href="https://ibb.co/64Md00Z"><img src="https://i.ibb.co/64Md00Z/visual-mode.gif" alt="visual-mode" border="0" /></a>

### Macros

Macros are a way to save a sequence of commands, and play them back later.

To record a macro, enter `q` and an arbitrary character to specify the `register` that the
macro will save into. Then, perform a series of actions, and finish recording by pressing
`q`.

<a href="https://ibb.co/z7zsS81"><img src="https://i.ibb.co/z7zsS81/macro-rec.gif"
alt="macro-rec" border="0" /></a>

You may play it back by entering `@` and the character you specified earlier. Optionally,
prefix it with a number to indicate the number of repetitions.

<a href="https://ibb.co/884T1fR"><img src="https://i.ibb.co/884T1fR/macro-play.gif" alt="macro-play" border="0" /></a>

## Some ideas to start with

```
o         # insert track
<Space>fc # show fx chain
a         # add fx
# add ReaSynth
<ESC>     # close fx window
im        # insert midi item
<Space>so # open in midi editor
0         # get to item start
a         # add note and select it
5p        # paste 5 more notes (last one is selected)
NN        # select two more previous notes
<M+k>     # move 3 notes up semitone
Z         # close midi editor
5+        # zoom horizonally 5 times
```

An alternative way if you wish to start recording straight ahead:

```
iv      # insert virtual instrument track
# Select ReaSynth. Track gets created and armed
<ESC>   # close fx window
R       # toggle record
# play some notes
<Enter> # stop recording
```

If you want to manipulate the item:

```
v # set mode visual
3l # jump right 3 grid divisions
o  # change time selection bound (to left one)
l  # jump right
!  # play and loop
```

If you want to adjust item volume:

```
<C+<Space>> # show mixer (for visual feedback)
10<C-J>     # -10db volume for track
```

## Help

Enter `<CM-x> (Ctrl + Alt + x)` to show a list of available bindings you can search and
filter.

<a href="https://ibb.co/hdd7HrH"><img src="https://i.ibb.co/hdd7HrH/binding-list.gif" alt="binding-list" border="0" /></a>

If you're stuck in a state you don't know how to get out of, you can press `<ESC>` to
reset back to normal.

Also, if your key press is not being detected, try unfocusing the feedback window.

## Tweaking

```
internal/definitions/actions.lua -> add actions
internal/definitions/bindings.lua -> add or customise key bindings
internal/definitions/config.lua -> change GUI settings
```

## Reporting performance issues

1. Download "Lua profiler" from ReaTeam Scripts and "ReaImGui" from ReaTeam Extensions via
ReaPack.
2. Change "profile" to "true" in internal/definitions/config.lua
3. In Reaper, click Actions > Running script > rk.lua > Terminate instances. There may be
no "Running script", then just skip this step.
4. Press any key. A profiler window will open.
5. Click "Acquisition > Stop" in the profiler window after you're done
6. Click "Copy to clipboard". Paste in a GitHub issue.
7. When you're done, change "profile" back to false and repeat (3)

## Further Information

Check out the [documentation](https://gwatcha.github.io/reaper-keys) to learn more.
