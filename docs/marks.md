---
title: Marks
nav_order: 4
---

# Marks

In any mode, the <kbd>m</kbd> key followed by a register key will store a mark which will save the current track selection, time selection, and edit cursor position.

If you are in visual mode, the mark also creates a visible region.
If you are in normal mode, the mark also creates a visible marker.
If you are in visual track mode, the mark does not create anything apart from the mark.

There are four actions that make use of stored marks.


| Key            | Action Name            | Action Type         | Function                     |
| -------------- | ---------------------- | ------------------- | ---------------------------- |
| {% raw %}`{% endraw %} | MarkedTimelinePosition | `timeline motion`   | Recalls edit cursor position |
| '            | MarkedTracks           | `track selector`    | Recalls selected tracks      |
| ~            | MarkedRegion           | `timeline selector` | Recalls timeline selection   |
| <C-'>        | DeleteMark             | `command`           | Deletes a stored mark        |

These actions compose just like any other actions of their type. 
