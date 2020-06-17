---
layout: default
title: Reaper-Keys Behaviour
nav_order: 3
parent: Configuration
---

# Reaper-Keys Behaviour

    ├── definitions
        └── config.lua

The `config` file has entries that tweak reaper-keys behaviour. One example is how verbose it's logging should be.

  ``` lua
  -- options in decreasing verbosity: [trace debug info warn user error fatal]
  log_level = 'warn',
  ```
