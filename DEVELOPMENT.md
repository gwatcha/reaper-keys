# Development
## Testing

You will need a Linux distribution providing

- `bash`
- `curl`
- `sed`
- `xdotool`
- `python 3.4+`
- either X11 or `Xvfb`

to run tests. See `.github/workflows/wf.yml` for running tests with `Xvfb`.

```sh
cd tests;
chmod +x prepare copy-configs test

./prepare # Create a local Reaper installation
./copy-configs # Point local installation to Reaper-keys
./test # Run every test and compare with reference projects
./test ololo.rks # Run one test
./test ololo.rks -s # Run one test in slow mode, retain test output file
```

Each test is a sequence of keys you press. One notable exception is a hotkey or
a special key like "Return" (Enter) or "Backspace". In that case, key should be
prefixed with `&` as in `&Return`.

You may find
[`.RPP` format documentation](https://github.com/ReaTeam/Doc/blob/master/State%20Chunk%20Definitions)
helpful if you want to write your own tests.

## Reporting performance issues

1. Download "Lua profiler" from ReaTeam Scripts and "ReaImGui" from ReaTeam
   Extensions via Reapack.
2. Change `profile` to `true` in `internal/definitions/config.lua`.
3. In Reaper, click Actions > Running script > rk.lua > Terminate instances.
   There may be no "Running script", then just skip this step.
4. Press any key. A profiler window will open.
5. Click "Acquisition > Stop" in the profiler window after you're done
6. Click "Copy to clipboard". Paste in a GitHub issue.
7. When you're done, change "profile" back to false and repeat (3)
