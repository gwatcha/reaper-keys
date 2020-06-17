---
layout: default
title: Visual Track
nav_order: 3
parent: Modes
---

# Visual Track Mode

Enter this mode by via <kbd>V</kbd> by default.

This mode is the same in principle as `visual timeline` mode, just with track motions/selections and track operators instead.

This means that in this mode, `track motion` and `track selection` action types extend or set the current track selection.

Also, the `track operator` type does not require a `track motion` or `track selection` to come before, as in normal mode, and instead operates immediately on the current track selection and then exits visual track mode.

It also allows for the execution of `visual_track_command` types.

## Available Action Sequences

| Action Sequence | Behaviour |
| --- | --- |
| `track selector` | Sets the track selection  |
| `track motion` | Extends the track selection up to the new track position after the motion |
| `track operator` | Executes the operator and exits to normal mode. |
| `visual track command` | Executes a visual track command. |
