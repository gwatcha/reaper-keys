---
layout: default
title: Visual Timeline
nav_order: 2
parent: Modes
---

# Visual Timeline Mode

Enter this mode by via <kbd>v</kbd> by default.

In this mode, `timeline_motion` and `timeline_selection` action types extend or set the current timeline selection.

Also the `timeline_operator` type does not require a `timeline_motion` or `timeline_selector` to come before, as in normal mode, and instead operates immediately
on the current timeline selection and then exits visual timeline mode.

It also allows for the execution of `visual_track_command` types.

## Available Action Sequences


| Action Sequence | Behaviour |
| --- | ---  |
| `timeline selector` | Sets the timeline selection  |
| `timeline motion` | Extends the timeline selection to the new edit cursor position  |
| `timeline operator` | Executes the operator and exits to normal mode. |
| `visual timeline command` | Executes a visual timeline command. |

