---
title: Modes
nav_order: 2
has_children: true
---

# Modes
1. {toc}

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

In this mode, `timeline_motion` and `timeline_selection` action types extend or set the current timeline selection.

Also the `timeline_operator` type does not require a `timeline_motion` or `timeline_selector` to come before, as in normal mode, and instead operates immediately
on the current timeline selection and then exits visual timeline mode.

It also allows for the execution of `visual_track_command` types.

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
