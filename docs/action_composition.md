---
title: Action Composition
---

# Action Composition

The main feature reaper-keys provides is the ability to compose actions of different types to create new commands. 

How one can compose action types (i.e. the available _action sequences_) and their behaviour when joined is dependant on the [mode](modes) of reaper-keys. 

Take as an example the `timeline motion` type as well as the `timeline operator` type. In normal mode, any `timeline motion` may precede any `timeline operator`. When this action sequence is entered, it will result in the `timeline operator` being called on the timeline section between the cursor position before the motion and after the motion.

So one could enter <kbd>sL</kbd>, to create `(s = "SelectItems", L = "NextMeasure")`, and select the items up to the next measure.

## Action Types

| Action Type | Description |
| ------ | ---- |
| `command` | A generic command. Does not compose, accessible from every mode |
| `timeline motion` | Moves the edit cursor somewhere on the timeline |
| `timeline selector` | Sets the timeline selection  |
| `timeline operator` | Executes a command that operates on the timeline selection |
| `track motion` | Changes the last touched track |
| `track selector` | Selects a track or multiple tracks |
| `track operator` | Executes a command that operates on a track selection |
| `visual timeline command` | A command only available in visual timeline mode |
| `visual track command` | A command only available in visual track mode |


