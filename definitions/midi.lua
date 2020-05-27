return {
  timeline_selector = {
    ["s"] = "SelectedNotes",
  },
  timeline_operator = {
    ["d"] = "CutNotes",
    ["y"] = "CopyNotes",
    ["i"] = "FitNotes",
    ["n"] = "InsertNote",
    ["g"] = "JoinNotes",
    ["s"] = "SelectNotes",
    ["z"] = "MidiZoomTimeSelection",
  },
  timeline_motion = {
    ["w"] = "NextNoteStart",
    ["b"] = "PrevNoteStart",
    ["W"] = "NextNoteSamePitchStart",
    ["B"] = "PrevNoteSamePitchStart",
    ["e"] = "EventSelectionEnd",
  },
  command = {
    ["+"] = "MidiZoomInVert",
    ["-"] = "MidiZoomOutVert",
    ["<C-+>"] = "MidiZoomInHoriz",
    ["<C-->"] = "MidiZoomOutHoriz",
    ["-"] = "MidiZoomOutVert", -- dupl of abover?
    ["p"] = "MidiPaste",
    ["<ESC>"] = "CloseWindow",
    ["S"] = "ClearNoteSelection",
    ["G"] = "JoinNotes",
    ["Y"] = "CopySelectedEvents",
    ["D"] = "CutSelectedEvents",
    ["k"] = "PitchUp",
    ["j"] = "PitchDown",
    ["K"] = "PitchUpOctave",
    ["J"] = "PitchDownOctave",
    ["<C-b>"] = "PitchUpOctave",
    ["<C-f>"] = "PitchDownOctave",
    ["<C-u>"] = "PitchUp7",
    ["<C-d>"] = "PitchDown7",
    ["o"] = "InsertNote",
    ["V"] = "SelectAllNotesAtPitch",
    ["<M-k>"] = "MoveNoteUpSemitone",
    ["<M-j>"] = "MoveNoteDownSemitone",
    ["<M-K>"] = "MoveNoteUpOctave",
    ["<M-J>"] = "MoveNoteDownOctave",
    ["<M-l>"] = "MoveNoteRight",
    ["<M-h>"] = "MoveNoteLeft",
    ["<C-G>"] = {"+set note length", {
        ["z"] = "SetMidiNoteLengthTo1By1",
        ["x"] = "SetMidiNoteLengthTo1By2",
        ["c"] = "SetMidiNoteLengthTo1By2dot",
        ["v"] = "SetMidiNoteLengthTo1By2trip",
        ["b"] = "SetMidiNoteLengthTo1By4",
        ["a"] = "SetMidiNoteLengthTo1By4dot",
        ["s"] = "SetMidiNoteLengthTo1By4trip",
        ["d"] = "SetMidiNoteLengthTo1By8",
        ["f"] = "SetMidiNoteLengthTo1By8dot",
        ["g"] = "SetMidiNoteLengthTo1By8trip",
        ["q"] = "SetMidiNoteLengthTo1By16",
        ["w"] = "SetMidiNoteLengthTo1By16dot",
        ["e"] = "SetMidiNoteLengthTo1By16trip",
        ["r"] = "SetMidiNoteLengthTo1By32",
        ["t"] = "SetMidiNoteLengthTo1By64",
    }}, -- i set it to B because I am not really sure which keys are available
  },
}
-- ["<SPC>"] = { "+leader commands", {

