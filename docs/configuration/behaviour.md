---
layout: default
title: Reaper-Keys Behaviour
nav_order: 3
parent: Configuration
---

# Reaper-Keys Behaviour

## Relevant Files

    ├── definitions
        └── config.lua
        
        
## Configuration

The `config` file has a table of options that tweaks reaper-keys behaviour.

| Option                                  | Values                                   | Use                                                                                                                     |
| ---                                     | ---                                      | ---                                                                                                                     |
| `log_level`                             | [trace debug info warn user error fatal] | sets log verbosity                                                                                                      |
| `persist_visual_timeline_selection`     | [true false]                             | controls if timeline operators in visual timeline mode reset the timeline selection                                     |
| `persist_visual_track_selection`        | [true false]                             | controls if track operators in visual track mode reset the track selection                                              |
| `allow_visual_track_timeline_movement`  | [true false]                             | controls if timeline movement in `visual track` mode is allowed                                                         |
| `repeatable_commands_action_type_match` | table of action type match strings       | controls which commands are considered repeatable by specifying the action type it should contain in its action sequence |
