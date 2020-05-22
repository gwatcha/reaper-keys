-- TODO Midi bindings are still a work in progress, I mostly re-record midi
-- instead of changing it by hand, so this part may come slow. Feel free to
-- add some yourself though!
return {
  timeline_selector = {},
  timeline_operator = {},
  timeline_motion = {
    ["<M-n>"] = "SelectNextNoteSamePitch",
    ["<M-p>"] = "SelectPrevNoteSamePitch",
    ["w"] = "SelectNextNoteSamePitch",
    ["b"] = "SelectPrevNoteSamePitch",
  },
  command = {
    ["k"] = "PitchCursorUp",
    ["j"] = "PitchCursorDown",
    ["K"] = "PitchCursorUpOctave",
    ["J"] = "PitchCursorDownOctave",
    ["<C-b>"] = "PitchCursorUpOctave",
    ["<C-f>"] = "PitchCursorDownOctave",
    ["<C-u>"] = "PitchCursorUp7",
    ["<C-d>"] = "PitchCursorDown7",
    ["<ESC>"] = "CloseWindow",
    ["<M-e>"] = "EditCursorRightMeasure",
    ["<M-q>"] = "EditCursorLeftMeasure",
    ["="] = "DoubleGridSize",
    ["+"] = "HalfGridSize",
    ["s"] = "AddNearestNoteToSelection",
    ["<SPC>,s"] = "ToggleMidiSnap",
    ["i"] = "InsertNote",
    ["V"] = "SelectAllNotesAtPitchCursor",
    ["n"] = "SelectNextNote",
    ["p"] = "SelectPrevNote",
    ["N"] = "SelectPrevNote",
    ["<M-k>"] = "MoveNoteUpSemitone",
    ["<M-j>"] = "MoveNoteDownSemitone",
    ["<M-K>"] = "MoveNoteUpOctave",
    ["<M-J>"] = "MoveNoteDownOctave",
    ["d"] = "DeleteNote",
    ["<M-l>"] = "MoveNoteRight",
    ["<M-h>"] = "MoveNoteLeft",
  },
}

