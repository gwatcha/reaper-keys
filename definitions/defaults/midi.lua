return {
  timeline_selector = {
    ["s"] = "SelectedNotes",
  },
  timeline_operator = {
    ["d"] = "CutNotes",
    ["y"] = "CopyNotes",
    ["c"] = "FitNotes",
    ["a"] = "InsertNote",
    ["g"] = "JoinNotes",
    ["s"] = "SelectNotes",
    ["z"] = "MidiZoomTimeSelection",
  },
  timeline_motion = {
    ["l"] = "RightMidiGridDivision",
    ["h"] = "LeftMidiGridDivision",
    ["("] = "MidiTimeSelectionStart",
    [")"] = "MidiTimeSelectionEnd",
    ["w"] = "NextNoteStart",
    ["b"] = "PrevNoteStart",
    ["W"] = "NextNoteSamePitchStart",
    ["B"] = "PrevNoteSamePitchStart",
    ["e"] = "EventSelectionEnd",
  },
  command = {
    ["n"] = "AddNextNoteToSelection",
    ["N"] = "AddPrevNoteToSelection",
    ["+"] = "MidiZoomInHoriz",
    ["-"] = "MidiZoomOutHoriz",
    -- ["gg"] = "TopNote",
    -- ["G"] = "BottomNote",
    ["<C-+>"] = "MidiZoomInVert",
    ["<C-->"] = "MidiZoomOutVert",
    ["Z"] = "CloseWindow",
    ["p"] = "MidiPaste",
    ["S"] = "UnselectAllEvents",
    ["Y"] = "CopySelectedEvents",
    ["D"] = "CutSelectedEvents",
    ["k"] = "PitchUp",
    ["j"] = "PitchDown",
    ["K"] = "PitchUpOctave",
    ["zp"] = "MidiZoomContent",
    -- [";"] = "MoveNotesToEditCursor", -- !!!!!!!!!!
    ["J"] = "PitchDownOctave",
    ["<C-b>"] = "PitchUpOctave",
    ["<C-f>"] = "PitchDownOctave",
    ["<C-u>"] = "PitchUp7",
    ["<C-d>"] = "PitchDown7",
    ["V"] = "SelectAllNotesAtPitch",
    ["<M-k>"] = "MoveNoteUpSemitone",
    ["<M-j>"] = "MoveNoteDownSemitone",
    ["<M-K>"] = "MoveNoteUpOctave",
    ["<M-J>"] = "MoveNoteDownOctave",
    ["<M-l>"] = "MoveNoteRight", -- move edit cursos only | needs to be fixed!!
    ["<M-h>"] = "MoveNoteLeft", -- move edit cursor only
    -- ["<M-L>"] = "MoveNoteRight", -- move note selection
    -- ["<M-H>"] = "MoveNoteLeft",  -- move note selection
  },
}

