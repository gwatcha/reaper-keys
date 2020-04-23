{
  actions = {
    -- ["<esc>"] = {
    --   "vim.reset()"
    -- }
    -- ["\""] = {
    --   "vim.reg()"
    -- },
    -- ["."] = {
    --   "vim.repeatLastAction()"
    -- },
    -- ["<ctrl>,"] = {
    --   "vim.openConfig()"
    -- },
    -- q = {
    --   "vim.recordMacro()"
    -- },
    -- v = {
    --   "vim.visualMode()"
    -- },
    ["<alt>l"] = {
      41144,
      "MidiLearnLastTouchedFX"
    },
    ['<alt>f'] = {
      "_BR_PLAY_MOUSECURSOR",
      "PlayFromMouse",
    },
    ["<alt>m"] = {
      41143,
      "ShowEnvelopeModulationLastTouchedFx"
    },
    ["<alt>s"] = {
      "_S&M_WNTGL5",
      "FxToggleShowAll"
    },
    ["<ctrl>N"] = {
      "_S&M_WNONLY1",
      "FxShowPrevSel"
    },
    ["<ctrl>c"] = {
      {
        "_S&M_WNMAIN",
        41074
      },
      "FocusMain, ToggleFloatingWindows"
    },
    ["<ctrl>f"] = {
      40073,
      "PlayPause"
    },
    ["<ctrl>g"] = {
      "_S&M_WNMAIN",
      "FocusMain"
    },
    ["<ctrl>n"] = {
      "_S&M_WNONLY2",
      "FxShowNextSel"
    },
    ["<ctrl>p"] = {
      "_S&M_WNONLY1",
      "FxShowPrevSel"
    },
    ["<ctrl>r"] = {
      40030,
      "Redo"
    },
    ["<ctrl>t"] = {
      40044,
      "StartStop"
    },
    C = {
      1013,
      "ToggleRecording"
    },
    u = {
      40029,
      "Undo"
    }
  },
  motions = {
    ["$"] = {
      40043,
      "GoProjectEnd"
    },
    ["0"] = {
      40042,
      "GoProjectBeginning"
    },
    ["<alt>H"] = {
      "vim.seq('<alt>h')",
      times = 4
    },
    ["<alt>L"] = {
      "vim.seq('<alt>l')",
      times = 4
    },
    ["<alt>h"] = {
      "_XENAKIOS_MOVECUR10PIX_LEFT",
      "CursorLeft10"
    },
    ["<alt>l"] = {
      "_XENAKIOS_MOVECUR10PIX_RIGHT",
      "CursorRight10"
    },
    ["<ctrl>H"] = {
      "vim.seq('H')",
      times = 4
    },
    ["<ctrl>L"] = {
      "vim.seq('L')",
      times = 4
    },
    ["<ctrl>a"] = {
      {"_XENAKIOS_SELFIRSTITEMSOFTRACKS", 41173},
      -- TODO restore selection
      "MoveToFirstItem"
    },
    ["<ctrl>h"] = {
      "vim.seq('h')",
      times = 4
    },
    ["<ctrl>l"] = {
      "vim.seq('l')",
      times = 4
    },
    H = {
      40840,
      "PrevMeasureNoSeek"
    },
    L = {
      40839,
      "NextMeasureNoSeek"
    },
    f = {
      40434,
      "MoveEditCursorToPlayCursor"
    },
    h = {
      40842,
      "PrevBeatNoSeek"
    },
    l = {
      40841,
      "NextBeatNoSeek"
    }
  },
  operators = {
    c = {
      "_SWS_AWRECORDCOND",
      "Change"
    },
    t = {
      1007,
      "Play"
    }
  }
}
