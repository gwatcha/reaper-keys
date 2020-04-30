{
  number = {
    ["[1-9][0-9]*"] = "Number"
  },
  register_location = {
    ["a-zA-Z0-9"] = "RegisterLocation"
  },
  register_action = {
    ["q"] = "RecordMaro",
    ["@"] = "PlayMacro",
    ['"'] = "PasteRegister",
    ["yf"] = "SaveFxChain",
  },
  internal_command = {
    ["<ESC>"] = {"ResetReaperKeys"},
    ["."] = {"RepeatLastAction"},
    ["<C-,>"] = {"OpenReaperKeysConfig"},
    ["v"] = {"VisualTimelineMode"},
  },
  timeline_selector = {},
  timeline_motion = {
    ["$"] = "GoProjectEnd",
    ["0"] = "GoProjectBeginning",
    ["f"] = "MoveEditCursorToPlayCursor",
    ["<M-H>"] = "CursorLeft40",
    ["<M-L>"] = "CursorRight40",
    ["<M-h>"] = "CursorLeft10",
    ["<M-l>"] = "CursorRight10",
    ["<C-a>"] = "MoveToFirstItem",
    ["H"] = "PrevMeasure",
    ["L"] = "NextMeasure",
    ["<C-H>"] = "Prev4Measures",
    ["<C-L>"] = "Next4Measures",
    ["h"] = "PrevBeat",
    ["l"] = "NextBeat",
    ["<C-h>"] = "Prev4Beats",
    ["<C-l>"] = "Next4Beats",
  },
  timeline_operator = {
    ["c"] = "Change",
    ["t"] = "Play",
  },
  action = {
    ["<M-l>"] = "MidiLearnLastTouchedFX",
    ["<M-f>"] = "PlayFromMouse",
    ["<M-m>"] = "ShowEnvelopeModulationLastTouchedFx",
    ["<M-s>"] = "FxToggleShowAll",
    ["<C-N>"] = "FxShowPrevSel",
    ["<C-c>"] = "ToggleFloatingWindows",
    ["<C-f>"] = "PlayPause",
    ["<C-g>"] = "FocusMain",
    ["<C-n>"] = "FxShowNextSel",
    ["<C-p>"] = "FxShowPrevSel",
    ["<C-r>"] = "Redo",
    ["<C-t>"] = "StartStop",
    ["C"] = "ToggleRecording",
    ["u"] = "Undo",
  },
}
