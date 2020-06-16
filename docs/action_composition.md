---
title: Action Composition
layout: default
---

# Action Composition

In Reaper-Keys, actions have a type associated with them. 

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

