return {
  timeline_motion = {
    ["0"] = "ProjectStart",
    ["f"] = "PlayPosition",
    ["x"] = "MousePosition",
    ["<left>"] = "PrevMarker",
    ["<right>"] = "NextMarker",
    ["<M-h>"] = "Left10Pix",
    ["<M-l>"] = "Right10Pix",
    ["h"] = "LeftGridDivision",
    ["l"] = "RightGridDivision",
    ["H"] = "PrevMeasure",
    ["L"] = "NextMeasure",
    ["<C-H>"] = "Prev4Measures",
    ["<C-L>"] = "Next4Measures",
    ["`"] = "MarkedTimelinePosition",
  },
  timeline_operator = {
    ["r"] = "Record",
    ["<C-p>"] = "DuplicateTimeline",
    ["t"] = "PlayAndLoop",
    ["|"] = "CreateMeasures",
    ["<C-|>"] = "CreateProjectTempo"
  },
  timeline_selector = {
    ["~"] = "MarkedRegion",
    ["<S-right>"] = "NextRegion",
    ["<S-left>"] = "PrevRegion",
    ["!"] = "LoopSelection",
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
    ["."] = "RepeatLastCommand",
    ["@"] = "PlayMacro",
    [","] = "RecordMacro",
    ["m"] = "Mark",
    ["~"] = "MarkedRegion",
    ["<C-'>"] = "DeleteMark",
    ["<S-right>"] = "NextRegion",
    ["<S-left>"] = "PrevRegion",
    ["<C-r>"] = "Redo",
    ["u"] = "Undo",
    ["R"] = "ToggleRecord",
    ["T"] = "Play",
    ["tt"] = "PlayFromTimeSelectionStart",
    ["<M-t>"] = "PlayFromMousePosition",
    ["<M-T>"] = "PlayFromMouseAndSoloTrack",
    ["F"] = "Pause",
    ["<C-z>"] = "ZoomUndo",
    ["<C-Z>"] = "ZoomRedo",
    ["v"] = "SetModeVisualTimeline",
    ["<M-v>"] = "ClearTimelineSelectionAndSetModeVisualTimeline",
    ["<C-SPC>"] = "ToggleViewMixer",
    ["<ESC>"] = "Reset",
    ["<return>"] = "StartStop",
    ["X"] = "MoveToMousePositionAndPlay",
    ["dr"] = "RemoveRegion",
    ["!"] = "ToggleLoop",
    ["<M-n>"] = "ShowNextFx",
    ["<M-N>"] = "ShowPrevFx",
    ["<M-g>"] = "FocusMain",
    ["<M-f>"] = "ToggleShowFx",
    ["<M-F>"] = "CloseFx",
    ["<CM-f>"] = "MidiLearnLastTouchedFxParam",
    ["<CM-m>"] = "ModulateLastTouchedFxParam",
    ["<M-x>"] = "ShowBindingList",
    ["<C-m>"] = "TapTempo",
    ["q"] = {"+options", {
               ["p"] = "TogglePlaybackPreroll",
               ["r"] = "ToggleRecordingPreroll",
               ["z"] = "TogglePlaybackAutoScroll",
               ["v"] = "ToggleLoopSelectionFollowsTimeSelection",
               ["s"] = "ToggleSnap",
               ["m"] = "ToggleMetronome",
               ["t"] = "ToggleStopAtEndOfTimeSelectionIfNoRepeat",
               ["x"] = "ToggleAutoCrossfade",
               ["e"] = "ToggleEnvelopePointsMoveWithItems",
               ["c"] = "CycleRippleEditMode",
               ["f"] = "ResetFeedbackWindow",
    }},
    ["<SPC>"] = { "+leader commands", {
      ["<SPC>"] = "ShowActionList",
      ["m"] = { "+midi", {
                  ["g"] = "SetMidiGridDivision",
                  ["q"] = "Quantize",
      }},
      ["r"] = { "+recording", {
                  ["o"] = "SetRecordMidiOutput",
                  ["d"] = "SetRecordMidiOverdub",
                  ["t"] = "SetRecordMidiTouchReplace",
                  ["R"] = "SetRecordMidiReplace",
                  ["v"] = "SetRecordMonitorOnly",
                  ["r"] = "SetRecordInput",
                  [","] = {"+options", {
                             ["n"] = "SetRecordModeNormal",
                             ["s"] = "SetRecordModeItemSelectionAutoPunch",
                             ["v"] = "SetRecordModeTimeSelectionAutoPunch",
                             ["p"] = "ToggleRecordingPreroll",
                             ["z"] = "ToggleRecordingAutoScroll",
                             ["t"] = "ToggleRecordToTapeMode",
                  }},
      }},
      ["a"] = { "+automation", {
                  ["r"] = "SetAutomationModeTrimRead",
                  ["R"] = "SetAutomationModeRead",
                  ["l"] = "SetAutomationModeLatch",
                  ["g"] = "SetAutomationModeLatchAndArm",
                  ["p"] = "SetAutomationModeLatchPreview",
                  ["t"] = "SetAutomationModeTouch",
                  ["w"] = "SetAutomationModeWrite",
      }},
      ["s"] = { "+selected items", {
                  ["j"] = "NextTake",
                  ["k"] = "PrevTake",
                  ["m"] = "ToggleMuteItem",
                  ["d"] = "DeleteActiveTake",
                  ["c"] = "CropToActiveTake",
                  ["o"] = "OpenInMidiEditor",
                  ["n"] = "ItemNormalize",
                  ["x"] = {"+explode takes", {
                             ["p"] = "ExplodeTakesInPlace",
                             ["o"] = "ExplodeTakesInOrder",
                             ["a"] = "ExplodeTakesInAcrossTracks"
                  }},
                  ["#"] = {"+fade", {
                             ["i"] = "CycleItemFadeInShape",
                             ["o"] = "CycleItemFadeOutShape",
                  }},
                  ["t"] = {"+transients", {
                             ["a"] = "AdjustTransientDetection",
                             ["t"] = "CalculateTransientGuides",
                             ["c"] = "ClearTransientGuides",
                             ["s"] = "SplitItemAtTransients"
                  }},
                  ["e"] = {"+envelopes", {
                             ["s"] = "ViewTakeEnvelopes",
                             ["m"] = "ToggleTakeMuteEnvelope",
                             ["p"] = "ToggleTakePanEnvelope",
                             ["P"] = "ToggleTakePitchEnvelope",
                             ["v"] = "ToggleTakeVolumeEnvelope",
                  }},
                  ["f"] = {"+fx", {
                             ["a"] = "ApplyFxToItem",
                             ["p"] = "PasteItemFxChain",
                             ["d"] = "CutItemFxChain",
                             ["y"] = "CopyItemFxChain",
                             ["c"] = "ToggleShowTakeFxChain",
                             ["b"] = "ToggleTakeFxBypass",
                  }},
                  ["r"] = {"+rename", {
                             ["s"] = "RenameTakeSourceFile",
                             ["t"] = "RenameTake",
                             ["r"] = "RenameTakeAndSourceFile",
                             ["a"] = "AutoRenameTake",
                  }},
                  ["b"] = { "+timebase", {
                              ["t"] = "SetItemsTimebaseToTime",
                              ["b"] = "SetItemsTimebaseToBeatsPos",
                              ["r"] = "SetItemsTimebaseToBeatsPosLengthAndRate",
                  }},
      }},
      ["t"] = { "+track", {
                  ["R"] = "RenderTrack",
                  ["r"] = "RenameTrack",
                  ["m"] = "CycleRecordMonitor",
                  ["f"] = "CycleFolderState",
                  ["y"] = "SaveTrackAsTemplate",
                  ["p"] = "InsertTrackFromTemplate",
                  ["1"] = "InsertTrackFromTemplateSlot1",
                  ["2"] = "InsertTrackFromTemplateSlot2",
                  ["3"] = "InsertTrackFromTemplateSlot3",
                  ["4"] = "InsertTrackFromTemplateSlot4",
                  ["c"] = "InsertClickTrack",
                  ["v"] = "InsertVirtualInstrumentTrack",
                  ["x"] = {"+routing", {
                            ["p"] = "TrackToggleSendToParent",
                            ["s"] = "ToggleShowTrackRouting",
                  }},
                  ["F"] = { "+freeze", {
                            ["f"] = "FreezeTrack",
                            ["u"] = "UnfreezeTrack",
                            ["s"] = "ShowTrackFreezeDetails",
                  }},
      }},
      ["e"] = {"+envelopes", {
                 ["t"]  = "ToggleShowAllEnvelope",
                 ["a"] = "ToggleArmAllEnvelopes",
                 ["A"] = "UnarmAllEnvelopes",
                 ["d"] = "ClearAllEnvelope",
                 ["v"] = "ToggleVolumeEnvelope",
                 ["p"] = "TogglePanEnvelope",
                 ["w"] = "SelectWidthEnvelope",
                 ["s"] = {"+selected", {
                            ["d"] = "ClearEnvelope",
                            ["a"] = "ToggleArmEnvelope",
                            ["t"] = "ToggleShowSelectedEnvelope",
                 }},
      }},
      ["f"] = { "+fx", {
                  ["a"] = "AddFx",
                  ["c"] = "ToggleShowFxChain",
                  ["d"] = "CutFxChain",
                  ["y"] = "CopyFxChain",
                  ["p"] = "PasteFxChain",
                  ["b"] = "ToggleFxBypass",
                  ["i"] = {"+input", {
                             ["s"] = "ToggleShowInputFxChain",
                             ["d"] = "CutInputFxChain",
                  }},
                  ["s"] = {"+show", {
                             ["1"] = "ToggleShowFx1",
                             ["2"] = "ToggleShowFx2",
                             ["3"] = "ToggleShowFx3",
                             ["4"] = "ToggleShowFx4",
                             ["5"] = "ToggleShowFx5",
                             ["6"] = "ToggleShowFx6",
                             ["7"] = "ToggleShowFx7",
                             ["8"] = "ToggleShowFx8"
                  }},
      }},
      ["g"] = { "+global", {
                  ["g"] = "SetGridDivision",
                  ["r"] = "ResetControlDevices",
                  [","] = "ShowPreferences",
                  ["S"] = "UnsoloAllItems",
                  ["s"] = {"+show/hide", {
                             ["x"] = "ToggleShowRoutingMatrix",
                             ["w"] = "ToggleShowWiringDiagram",
                             ["t"] = "ToggleShowTrackManager",
                             ["m"] = "ShowMasterTrack",
                             ["M"] = "HideMasterTrack",
                             ["r"] = "ToggleShowRegionMarkerManager",
                  }},
                  ["f"] = {"+fx", {
                             ["x"] = "CloseAllFxChainsAndWindows",
                             ["c"] = "ViewFxChainMaster",
                  }},
                  ["e"] = { "+envelope", {
                            ["t"] = "ToggleShowAllEnvelopeGlobal",
                  }},
                  ["t"] = { "+track", {
                            ["t"] = "ToggleAutomaticRecordArm",
                            ["a"] = "ClearAllRecordArm",
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
                  [","] = "ShowProjectSettings",
                  ["n"] = "NextTab",
                  ["p"] = "PrevTab",
                  ["s"] = "SaveProject",
                  ["o"] = "OpenProject",
                  ["c"] = "NewProjectTab",
                  ["x"] = "CloseProject",
                  ["C"] = "CleanProjectDirectory",
                  ["S"] = "SaveProjectWithNewVersion",
                  ["r"] = { "+render", {
                              ["."] = "RenderProjectWithLastSetting",
                              ["r"] = "RenderProject",
                  }},
      }},
    }},
  },
}
