---
layout: default
title: Bindings
nav_order: 1
parent: Configuration
---

# Bindings

## Relevant Files

    ├── definitions
        ├── global.lua
        ├── main.lua
        └── midi.lua


## Configuration

```lua
-- add a binding by specifying a key sequence and an action name

-- remove a binding by specifying an action with no name
["<SPC>"] = "",

-- overwrite an entire folder by changing the name
["<SPC>"] = { "+new folder name", {
                ["<C-b>"] = "ShowBindingList"
}},

-- overwrite or add a binding in a folder by keeping the name the same
["<SPC>"] = { "+leader commannds", {
                ["<C-b>"] = "ShowBindingList"
                ["b"] = "",
}},
```

The `global`, `main`, and `midi` files contain default binding definitions (i.e. 'key sequence -> action' mappings)


You may define or change key sequences for a specific context (in `main` or `midi`) or for all contexts (in `global`).

The entries in these files are organized by `action type`.

Here is an example snippet that declares some bindings in the `timeline operator`
action type section.

```lua
timeline_operator = {
    ["r"] = "Record",
    ["t"] = "PlayAndLoop",
  },
```  

Actions may also be put into folders. To create a folder,  follow this format:

``` lua
command = {
  ["<SPC>"] = { "+leader commands", {
    ["<SPC>"] = "ShowBindingList",
    ["b"] = "ShowBindingList",
    ["m"] = { "+midi", {
                ["x"] = "CloseWindow",
                ["g"] = "SetMidiGridDivision",
                ["q"] = "Quantize",
                [","] = {"+options", {
                            ["g"] = "ToggleMidiEditorUsesMainGridDivision",
                            ["s"] = "ToggleMidiSnap",

                }},
    }},
}
``` 
