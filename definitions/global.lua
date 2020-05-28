return {
  register_action = {},
  meta_command = {
    ["."] = "RepeatLastCommand",
    ["@"] = "PlayMacro",
    ["q"] = "RecordMacro",
    ["<SPC>h"] = "ShowReaperKeysHelp",
  },
  timeline_motion = {
    ["0"] = "ProjectStart",
    ["<C-$>"] = "ProjectEnd",
    ["f"] = "PlayPosition",
    ["["] = "LoopStart",
    ["]"] = "LoopEnd",
    ["("] = "TimeSelectionStart",
    [")"] = "TimeSelectionEnd",
    ["<left>"] = "PrevMarker",
    ["<right>"] = "NextMarker",
    ["x"] = "MouseAndSnap",
    ["X"] = "Mouse",
    ["<M-h>"] = "Left10Pix",
    ["<M-l>"] = "Right10Pix",
    ["<M-H>"] = "Left40Pix",
    ["<M-L>"] = "Right40Pix",
    ["h"] = "LeftGridDivision",
    ["l"] = "RightGridDivision",
    ["H"] = "PrevMeasure",
    ["L"] = "NextMeasure",
    ["<C-h>"] = "Prev4Beats",
    ["<C-l>"] = "Next4Beats",
    ["<C-H>"] = "Prev4Measures",
    ["<C-L>"] = "Next4Measures",
  },
  timeline_operator = {
    ["<M-r>"] = "InsertRegion",
    ["r"] = "Record",
    ["t"] = "PlayAndLoop",
  },
  timeline_selector = {
    ["v"] = "TimeSelection",
    [";"] = "NextRegion",
    [","] = "PrevRegion",
    ["!"] = "LoopSelection", -- this one toggles repeat?!
    ["i"] = {"+inner", {
               ["<M-w>"] = "AutomationItem",
               ["l"] = "AllTrackItems",
               ["r"] = "Region",
               ["p"] = "ProjectTimeline",
               ["w"] = "Item",
               ["W"] = "BigItem",
    }},
  },
  visual_timeline_command = {
    ["v"] = "SetModeNormal",
    ["o"] = "SwitchTimelineSelectionSide",
  },
  command = {
    ["<C-r>"] = "Redo",
    ["u"] = "Undo",
    ["R"] = "RecordOrStop",
    ["T"] = "TransportPlay",
    ["F"] = "TransportPause",
    ["zt"] = "ScrollToPlayPosition",
    ["<C-i>"] = "ZoomRedo",
    ["<C-o>"] = "ZoomUndo",
    ["<M-i>"] = "MoveRedo",
    ["<M-o>"] = "MoveUndo",
    [">"] = "ShiftTimeSelectionRight",
    ["v"] = "SetModeVisualTimeline",
    ["<"] = "ShiftTimeSelectionLeft",
    ["<CM-SPC>"] = "ToggleViewMixer",
    ["<ESC>"] = "Reset",
    ["<return>"] = "StartStop",
    ["<M-T>"] = "MoveToMouseAndPlay",
    ["<M-t>"] = "PlayFromMouse",
    ["<M-m>"] = "MidiLearnLastTouchedFX",
    ["<M-M>"] = "ShowEnvelopeModulationLastTouchedFx",
    ["<M-g>"] = "FocusMain",
    ["<M-f>"] = "FxToggleShow",
    ["<M-F>"] = "FxClose",
    ["<M-n>"] = "FxShowNextSel",
    ["<M-N>"] = "FxShowPrevSel",
    ["dr"] = "RemoveRegion",
    ["mi"] = "MarkerInsert",
    ["dm"] = "RemoveMarker",
    ["!"] = "ToggleLoop",
    ["<SPC>"] = { "+leader commands", {
      ["<SPC>"] = "ShowActionList",
      ["h"] = "ShowReaperKeysHelp",
      ["m"] = { "+midi", {
                  ["x"] = "CloseWindow",
                  [","] = {"+options", {
                             ["q"] = "Quantize",
                             ["s"] = "ToggleMidiSnap",
                  }},
      }},
      ["r"] = { "+recording", {
                  ["o"] = "SetTrackRecMidiOutput",
                  ["d"] = "SetTrackRecMidiOverdub",
                  ["t"] = "SetTrackRecMidiTouchReplace",
                  ["r"] = "SetTrackRecMidiReplace",
                  ["m"] = "SetTrackRecMonitorOnly",
                  ["i"] = "SetTrackRecInput",
                  ["a"] = "SetTrackRecInput",
                  [","] = {"+options", {
                             ["p"] = "ToggleRecordingPreroll",
                             ["z"] = "ToggleRecordingAutoScroll",
                             ["n"] = "SetRecordModeNormal",
                  }},
      }},
      ["s"] = { "+item selection", {
                  ["ci"] = "CycleItemFadeInShape",
                  ["co"] = "CycleItemFadeOutShape",
                  ["j"] = "NextTake",
                  ["k"] = "PrevTake",
                  ["d"] = "DeleteActiveTake",
                  ["s"] = "CropToActiveTake",
                  ["e"] = "OpenMidiEditor",
                  ["n"] = "ItemNormalize",
                  ["r"] = "ItemApplyFX",
                  ["g"] = "GroupItems",
      }},
      ["t"] = { "+track", {
                  ["n"] = "ResetTrackToNormal",
                  ["R"] = "RenderTrack",
                  ["i"] = "AddTrackVirtualInstrument",
                  ["r"] = "RenameTrack",
                  ["z"] = "MinimizeTracks",
                  ["M"] = "CycleRecordMonitor",
                  ["f"] = "CycleFolderState",
                  ["x"] = {"+routing", {
                             ["i"] = "TrackSetInputToMatchFirstSelected",
                             ["s"] = "ShowTrackRouting",
                  }},
                  ["F"] = { "+freeze", {
                    ["f"] = "FreezeTrack",
                    ["u"] = "UnfreezeTrack",
                    ["s"] = "ShowTrackFreezeDetails",
                  }},
                  ["e"] = { "+envelopes", {
                              ["s"]  = "ToggleShowAllEnvelope",
                              ["a"] = "ToggleArmAllEnvelopes",
                              ["A"] = "UnarmAllEnvelopes",
                              ["d"] = "ClearAllEnvelope",
                              ["v"] = "ToggleVolumeEnvelope",
                              ["p"] = "TogglePanEnvelope",
                  }},
      }},
      ["a"] = { "+automation", {
                  ["r"] = "SetAutomationModeTrimRead",
                  ["R"] = "SetAutomationModeRead",
                  ["g"] = "SetAutomationModeLatchAndArm",
                  ["l"] = "SetAutomationModeLatch",
                  ["p"] = "SetAutomationModeLatchPreview",
                  ["t"] = "SetAutomationModeTouch",
                  ["c"] = "SetAutomationModeTouchAndArm",
                  ["w"] = "SetAutomationModeWrite",
      }},
      ["e"] = {"+envelope", {
                 ["a"] = "ToggleArmEnvelope",
                 ["d"] = "ClearEnvelope",
                 ["y"] = "CopyEnvelope",
                 ["t"] = "ToggleShowSelectedEnvelope",
                 ["s"] = {"+shape", {
                            ["b"] = "SetEnvelopeShapeBezier",
                            ["e"] = "SetEnvelopeShapeFastEnd",
                            ["f"] = "SetEnvelopeShapeFastStart",
                            ["l"] = "SetEnvelopeShapeLinear",
                            ["s"] = "SetEnvelopeShapeSlowStart",
                            ["S"] = "SetEnvelopeShapeSquare",
                 }},
      }},
      ["f"] = { "+fx", {
                  ["a"] = "FxAdd",
                  ["b"] = "TrackToggleFXBypass",
                  ["c"] = {"+chain", {
                            ["s"] = "FxChainToggleShow",
                            ["i"] = "ViewFxChainInputCurrentTrack",
                            ["di"] = "ClearFxChainInputCurrentTrack",
                            ["d"] = "ClearFxChainCurrentTrack",
                            ["y"] = "CopyFxChain",
                            ["p"] = "PasteFxChain",
                  }},
                  ["s"] = {"+show", {
                             ["1"] = "FxToggleShow1",
                             ["2"] = "FxToggleShow2",
                             ["3"] = "FxToggleShow3",
                             ["4"] = "FxToggleShow4",
                             ["5"] = "FxToggleShow5",
                             ["6"] = "FxToggleShow6",
                             ["7"] = "FxToggleShow7",
                             ["8"] = "FxToggleShow8",
                  }},
      }},
      [","] = {"+options", {
                 ["v"] = "ToggleLoopSelectionFollowsTimeSelection",
                 ["s"] = "ToggleSnap",
                 ["c"] = "CycleRippleEditMode",
                 ["m"] = "ToggleMetronome",
                 ["t"] = "ToggleStopAtEndOfTimeSelectionIfNoRepeat",
                 ["i"] = "ToggleAutoCrossfade",
                 ["zt"] = "TogglePlaybackAutoScroll",
                 ["e"] = "ToggleEnvelopePointsMoveWithItems",
      }},
      ["g"] = { "+global", {
                  ["s"] = {"+show", {
                             ["x"] = "ShowRoutingMatrix",
                             ["w"] = "ShowWiringDiagram",
                             ["t"] = "ShowTrackManager",
                             ["p"] = "Preferences",
                  }},
                  ["A"] = "ClearAllRecordArm",
                  ["dr"] = "ResetControlDevices",
                  ["f"] = {"+fx", {
                             ["x"] = "FxCloseAll",
                             ["c"] = "ViewFxChainMaster",
                  }},
                  ["t"] = { "+track", {
                      ["e"] = { "+envelope", {
                              ["s"] = "ToggleShowAllEnvelopeGlobal",
                      }},
                      ["s"] = "UnsoloAllTracks",
                      ["m"] = "UnmuteAllTracks",
                  }},
                  ["a"] = { "+automation", {
                              ["r"] = "SetGlobalAutomationModeTrimRead",
                              ["l"] = "SetGlobalAutomationModeLatch",
                              ["p"] = "SetGlobalAutomationModeLatchPreview",
                              ["t"] = "SetGlobalAutomationModeTouch",
                              ["R"] = "SetGlobalAutomationModeRead",
                              ["w"] = "SetGlobalAutomationModeWrite",
                              ["S"] = "SetGlobalAutomationModeOff",
                  }},
      }},
      ["p"] = { "+project", {
                ["r"] = { "+render", {
                            ["."] = "RenderProjectWithLastSetting",
                            ["r"] = "RenderProject",
                        }},
                ["n"] = "NextTab",
                ["p"] = "PrevTab",
                ["N"] = "PrevTab",
                ["s"] = "SaveProject",
                ["o"] = "OpenProject",
                ["c"] = "NewProjectTab",
                ["d"] = "CloseProject",
                ["x"] = "CleanProjectDirectory",
            }},
    ["G"] = {"+grid",{ -- !!bug: for some reason some of these commands also execute other commands.
            ["m"] = { "+midi grid", {
                ["z"] = "GridMidiSetTo1by1", -- low left hand
                ["x"] = "GridMidiSetTo1by2",
                ["c"] = "GridMidiSetTo1by3",
                ["v"] = "GridMidiSetTo1by4", -- for some rear
                ["b"] = "GridMidiSetTo1by5",

                ["a"] = "GridMidiSetTo1by6", -- mid left hand
                ["s"] = "GridMidiSetTo1by7",
                ["d"] = "GridMidiSetTo1by8",
                ["f"] = "GridMidiSetTo1by9",
                ["g"] = "GridMidiSetTo1by10",

                ["q"] = "GridMidiSetTo1by12", -- upper left hand
                ["w"] = "GridMidiSetTo1by16",
                ["e"] = "GridMidiSetTo1by18",
                ["r"] = "GridMidiSetTo1by24",
                ["t"] = "GridMidiSetTo1by32",

                ["n"] = "GridMidiSetTo1by48", -- lower right
                ["m"] = "GridMidiSetTo1by64",
                [","] = "GridMidiSetTo1by128",
                ["."] = "GridMidiSetTo2by1",
                ["/"] = "GridMidiSetTo2by3",

                ["h"] = "GridMidiSetTo3by1", -- mid right
                ["j"] = "GridMidiSetTo4by1",

                ["y"] = "GridMidiSetGridTypeDotted", -- top right
                ["u"] = "GridMidiSetGridTypeStraight",
                ["i"] = "GridMidiSetGridTypeSwing",
                ["o"] = "GridMidiSetGridTypeTriplet",
            }},
            ["t"] = {"+main grid", {
                ["z"] = "GridSetTo1by1", -- low left hand
                ["x"] = "GridSetTo1by2",
                ["c"] = "GridSetTo1by3",
                ["v"] = "GridSetTo1by4",
                ["b"] = "GridSetTo1by5",

                ["a"] = "GridSetTo1by6", -- mid left hand
                ["s"] = "GridSetTo1by7",
                ["d"] = "GridSetTo1by8",
                ["f"] = "GridSetTo1by9",
                ["g"] = "GridSetTo1by10",

                ["q"] = "GridSetTo1by12", -- upper left hand
                ["w"] = "GridSetTo1by16",
                ["e"] = "GridSetTo1by18",
                ["r"] = "GridSetTo1by24",
                ["t"] = "GridSetTo1by32",

                ["n"] = "GridSetTo1by48", -- lower right
                ["m"] = "GridSetTo1by64",
                [","] = "GridSetTo1by128",
                ["."] = "GridSetTo2by1",
                ["/"] = "GridSetTo2by3",

                ["h"] = "GridSetTo3by1", -- mid right
                ["j"] = "GridSetTo4by1",

            }},
            ["a"] = {"+both grids", {
                ["z"] = "GridAllSetTo1by1", -- low left hand
                ["x"] = "GridAllSetTo1by2",
                ["c"] = "GridAllSetTo1by3",
                ["v"] = "GridAllSetTo1by4",
                ["b"] = "GridAllSetTo1by5",

                ["a"] = "GridAllSetTo1by6", -- mid left hand
                ["s"] = "GridAllSetTo1by7",
                ["d"] = "GridAllSetTo1by8",
                ["f"] = "GridAllSetTo1by9",
                ["g"] = "GridAllSetTo1by10",

                ["q"] = "GridAllSetTo1by12", -- upper left hand
                ["w"] = "GridAllSetTo1by16",
                ["e"] = "GridAllSetTo1by18",
                ["r"] = "GridAllSetTo1by24",
                ["t"] = "GridAllSetTo1by32",

                ["n"] = "GridAllSetTo1by48", -- lower right
                ["m"] = "GridAllSetTo1by64",
                [","] = "GridAllSetTo1by128",
                ["."] = "GridAllSetTo2by1",
                ["/"] = "GridAllSetTo2by3",

                ["h"] = "GridAllSetTo3by1", -- mid right
                ["j"] = "GridAllSetTo4by1",

            }},
        }},
    }},
  },
}
