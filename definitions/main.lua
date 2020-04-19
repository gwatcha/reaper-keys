{
  actions = {
    ["%"] = {
      40131,
      "CropToActiveTake"
    },
    ["("] = {
      40222,
      "SetLoopStart"
    },
    [")"] = {
      40223,
      "SetLoopEnd"
    },
    ["+"] = {
      1012,
      "ZoomInHoriz"
    },
    ["-"] = {
      1011,
      "ZoomOutHorizon"
    },
    [";;"] = {
      "_SWSSNAPSHOT_GET",
      "SnapshotsRecallCurrent1"
    },
    [";S"] = {
      "_SWSSNAPSHOT_NEW",
      "SnapshotsAddNew"
    },
    [";c"] = {
      "_SWSSNAPSHOT_NEW",
      "SnapshotsAddNew"
    },
    [";d"] = {
      "_SWSSNAPSHOT_DELCUR",
      "SnapshotsDeleteCurrent"
    },
    [";n"] = {
      "_SWSSNAPSHOT_GET_NEXT",
      "SnapshotsRecallNext"
    },
    [";o"] = {
      "_SWSSNAPSHOT_NEWEDIT",
      "SnapshotsAddAndName"
    },
    [";p"] = {
      "_SWSSNAPSHOT_GET_PREVIOUS",
      "SnapshotsRecallPrev"
    },
    [";r0"] = {
      "_SWSSNAPSHOT_GET",
      "SnapshotsRecallCurrent"
    },
    [";r1"] = {
      "_SWSSNAPSHOT_GET1",
      "SnapshotsRecall1"
    },
    [";r2"] = {
      "_SWSSNAPSHOT_GET2",
      "SnapshotsRecall2"
    },
    [";r3"] = {
      "_SWSSNAPSHOT_GET3",
      "SnapshotsRecall3"
    },
    [";r4"] = {
      "_SWSSNAPSHOT_GET4",
      "SnapshotsRecall4"
    },
    [";r5"] = {
      "_SWSSNAPSHOT_GET5",
      "SnapshotsRecall5"
    },
    [";r6"] = {
      "_SWSSNAPSHOT_GET6",
      "SnapshotsRecall6"
    },
    [";r7"] = {
      "_SWSSNAPSHOT_GET7",
      "SnapshotsRecall7"
    },
    [";r8"] = {
      "_SWSSNAPSHOT_GET8",
      "SnapshotsRecall8"
    },
    [";r9"] = {
      "_SWSSNAPSHOT_GET9",
      "SnapshotsRecall9"
    },
    [";s0"] = {
      "_SWSSNAPSHOT_SAVE",
      "SnapshotsSaveCurrent"
    },
    [";s1"] = {
      "_SWSSNAPSHOT_SAVE1",
      "SnapshotsSave1"
    },
    [";s2"] = {
      "_SWSSNAPSHOT_SAVE2",
      "SnapshotsSave2"
    },
    [";s3"] = {
      "_SWSSNAPSHOT_SAVE3",
      "SnapshotsSave3"
    },
    [";s4"] = {
      "_SWSSNAPSHOT_SAVE4",
      "SnapshotsSave4"
    },
    [";s5"] = {
      "_SWSSNAPSHOT_SAVE5",
      "SnapshotsSave5"
    },
    [";s6"] = {
      "_SWSSNAPSHOT_SAVE6",
      "SnapshotsSave6"
    },
    [";s7"] = {
      "_SWSSNAPSHOT_SAVE7",
      "SnapshotsSave7"
    },
    [";s8"] = {
      "_SWSSNAPSHOT_SAVE8",
      "SnapshotsSave8"
    },
    [";s9"] = {
      "_SWSSNAPSHOT_SAVE9",
      "SnapshotsSave9"
    },
    [";ss"] = {
      "_SWSSNAPSHOT_SAVE",
      "SnapshotsSaveCurrent"
    },
    [";w"] = {
      "_SWSSNAPSHOT_OPEN",
      "SnapshotsOpenWindow"
    },
    ["<"] = {
      40225,
      "GrowItemLeft"
    },
    ["<alt>j"] = {
      41864,
      "NextEnvelope"
    },
    ["<alt>k"] = {
      41863,
      "PrevEnvelope"
    },
    ["<alt>s"] = {
      "_S&M_WNTGL5",
      "FxToggleShowAll"
    },
    ["<alt>w"] = {
      "_S&M_WNMAIN",
      "FocusMain"
    },
    ["<ctrl>+"] = {
      40111,
      "ZoomInVert"
    },
    ["<ctrl>-"] = {
      40112,
      "ZoomOutVert"
    },
    ["<ctrl><"] = {
      40228,
      "ShrinkItemRight"
    },
    ["<ctrl>>"] = {
      40226,
      "ShrinkItemLeft"
    },
    ["<ctrl>N"] = {
      "_S&M_WNONLY1",
      "FxShowPrevSel"
    },
    ["<ctrl>i"] = {
      "_SWS_REDOZOOM",
      "ZoomRedo"
    },
    ["<ctrl>m"] = {
      1134,
      "TapTempo"
    },
    ["<ctrl>n"] = {
      "_S&M_WNONLY2",
      "FxShowNextSel"
    },
    ["<ctrl>o"] = {
      "_SWS_UNDOZOOM",
      "ZoomUndo"
    },
    ["<ctrl>p"] = {
      "_S&M_WNONLY1",
      "FxShowPrevSel"
    },
    ["<ctrl>u"] = {
      40286,
      "PrevTrack",
      times = 5
    },
    ["<ctrl>v"] = {
      40078,
      "ToggleViewMixer"
    },
    [">"] = {
      40228,
      "40228"
    },
    O = {
      { "_SWS_INSRTTRKABOVE", 
        "_SWS_COLTRACKNEXT",
        40696},
      "InsertTrackAbove, ColorTrackNext, RenameTrack"
    },
    P = {
      {40286, "_SWS_AWPASTE"},
      "PrevTrack, Paste"
    },
    R = {
      1068,
      "ToggleLoop"
    },
    V = {
        40421,
      "SelectItemsInTrack"
    },
    ["["] = {
      40632,
      "GoToLoopStart"
    },
    ["]"] = {
      40633,
      "GoToLoopEnd"
    },
    _ = {
      40129,
      "DeleteActiveTake"
    },
    dd = {
      {40210,  40005,  40286,  40285},
      "CopyTrack, RemoveTrack, PrevTrack, NextTrack"
    },
    dr = {
      {"_S&M_SPLIT11", 40699},
      "RegionSelItems, DelRegionAdaptive"
    },
    ds = {
      40089,
      "DelEnvelopeInRegion"
    },
    fN = {
      "_SWS_SELPREVMORR",
      "RegionGoToSelectPrev"
    },
    fn = {
      "_SWS_SELNEXTMORR",
      "RegionGoToSelectNext"
    },
    fp = {
      "_SWS_SELPREVMORR",
      "RegionGoToSelectPrev"
    },
    ["g;c"] = {
      "_SWSSNAPSHOT_NEWALL",
      "SnapshotsAddNewAllTracks"
    },
    o = {
      {40001,  "_SWS_COLTRACKPREV",  40696},
      "InsertTrack, ColorTrackPrev, RenameTrack"
    },
    p = {
      "_SWS_AWPASTE",
      "Paste"
    },
    ["r<space>f"] = {
      {41588,  41385}, 
      "GlueItems, RegionFitItems"
    },
    ["r<space>s"] = {
      40061,
      "RegionSplitItems"
    },
    rH = {
      40222,
      "SetLoopStart"
    },
    rL = {
      40223,
      "SetLoopEnd"
    },
    rN = {
      "_SWS_SELPREVREG",
      "RegionSelectPrev"
    },
    rh = {
      40632,
      "GoToLoopStart"
    },
    rl = {
      40633,
      "GoToLoopEnd"
    },
    rn = {
        "_SWS_SELNEXTREG",
      "RegionSelectNext"
    },
    rp = {
        "_SWS_SELPREVREG",
      "RegionSelectPrev"
    },
    rr = {
        40174,
      "RegionInsertFromSel"
    },
    ["v<space>g"] = {
      40034,
      "SelectItemsInGroups"
    },
    vN = {
      "_SWS_SELPREVREG",
      "RegionSelectPrev"
    },
    vg = {
      40182,
      "SelectAllItems"
    },
    vig = {
      40296,
      "SelectAllTracks"
    },
    vn = {
      "_SWS_SELNEXTREG",
      "RegionSelectNext"
    },
    vp = {
      "_SWS_SELPREVREG",
      "RegionSelectPrev"
    },
    vr = {
      40717,
      "SelectRegionItems"
    },
    x = {
      40699,
      "CutItem"
    },
    yf = {
        "_S&M_SMART_CPY_FXCHAIN",
      "CopyFxChain"
    },
    yy = {
      40210,
      "CopyTrack"
    },
    z1 = {
      40444,
      "TrackView.Load_1"
    },
    z2 = {
      40445,
      "TrackView.Load_2"
    },
    z3 = {
      40446,
      "TrackView.Load_3"
    },
    z4 = {
      40447,
      "TrackView.Load_4"
    },
    z5 = {
      40448,
      "TrackView.Load_5"
    },
    z6 = {
      40449,
      "TrackView.Load_6"
    },
    z7 = {
      40450,
      "TrackView.Load_7"
    },
    z8 = {
      40451,
      "TrackView.Load_8"
    },
    z9 = {
        40452,
      "TrackView.Load_9"
    },
    zf = {
      {"_SWS_SAVESEL",
       "_SWS_SELNEARESTPREVFOLDER",
       "_SWS_UNCOLLAPSE",
       "_SWS_SELCHILDREN",
       "_SWS_VZOOMFITMIN",
       "_SWS_TOGSAVESEL"},
      "ZoomFolder",
    },
    zi = {
      "_SWS_ITEMZOOM",
      "ZoomItemSelection"
    },
    zig = {
         {40295,  "_SWS_SAVESEL",  40296, "_SWS_VZOOMFITMIN", "_SWS_TOGSAVESEL"},
      "ZoomAllTracks"
    },
    zm1 = {
      40464,
      "TrackView.Save_1"
    },
    zm2 = {
        40465,
      "TrackView.Save_2"
    },
    zm3 = {
        40466,
      "TrackView.Save_3"
    },
    zm4 = {
      40467,
      "TrackView.Save_4"
    },
    zm5 = {
      40468,
      "TrackView.Save_5"
    },
    zm6 = {
      40469,
      "TrackView.Save_6"
    },
    zm7 = {
      40470,
      "TrackView.Save_7"
    },
    zm8 = {
      40471,
      "TrackView.Save_8"
    },
    zm9 = {
      40472,
      "TrackView.Save_9"
    },
    zr = {
      40031,
      "ZoomTimeSelection"
    },
    zs = {
      {40031,  "_SWS_VZOOMFITMIN"}, 
      "ZoomTimeSelection, ZoomTrackSelection"
    },
    zt = {
      "_SWS_VZOOMFITMIN",
      "ZoomTrackSelection"
    },
    zv = {
      "_SWS_ITEMZOOM",
      "ZoomItemSelection"
    },
    zz = {
      40913,
      "ScrollToSelectedTrack"
    },
    ["{"] = {
      40126,
      "PrevTake"
    },
    ["}"] = {
      40125,
      "NextTake"
    },
    ["<space>"] = { "", {
      ["<space>"] = {
        40605,
        "ShowActionList"
      },
      ["d"] = {40006, "DeleteItem"},
      ["y"] = {40698, "CopyItem"},
      ["p"] = {40058, "PasteItem"},
      ["m"]= { "markers", {
                -- ["a"] = Marker.Add,
                -- ["mg"] = Marker.Go,
                ["n"] = {40173, "NextMarker"},
                ["N"] = {40172, "PrevMarker"},
                ["p"] = {40172, "PrevMarker"},
      }},
      ["i"] = { "items", {
                  ["e"] = {40153, "OpenMidiEditor"},
                  ["n"] = {40108, "ItemNormalize"},
                  ["f"] = {40209, "ItemApplyFX"},
                  ["s"] = {"_SWS_AWSPLITXFADELEFT", "ItemSplitSelRight"},
                  ["G"] = {41588, "GlueItems"},
                  ["g"] = {40032, "GroupItems"},
                  ["h"] = {41306, "MoveItemLeftToEditCursor"},
                  ["l"] = {41307, "MoveItemRightToEditCursor"},
                  ["th"] = {41305, "TrimItemLeftToEditCursor"},
                  ["tl"] = {41311, "TrimItemRightToEditCursor"},
      }},
      ["t"] = { "tracks", {
                  ["x"] = {40293, "ShowTrackRouting"},
                  ["r"] = {"_SWS_AWRENDERSTEREOSMART", "RenderTrack"},
                  ["f"] = { "freeze", {
                    ["f"] = {41223, "FreezeTrack"},
                    ["u"] = {41644, "UnfreezeTrack"},
                    ["s"] = {41654, "ShowTrackFreezeDetails"}}},
                  ["s"] = {7, "ToggleSoloTracks"},
                  ["m"] = {6, "ToggleMuteTracks"},
                  ["a"] = {40495, "CycleRecordMonitor"},
                  ["i"] = {40701, "AddTrackVirtualInstrument"},
                  ["o"] = {40001, "InsertTrack"},
                  ["r"] = {40696, "RenameTrack"},
                  ["c"] = {40360, "ColorTrack"},
                  ["e"] = {"_S&M_MIDI_INPUT_ALL_CH", "SetTrackMidiAllChannels"},
                  ["+"] = {41325, "IncreaseTrackHeight"},
                  ["-"] = {41326, "DecreaseTrackHeight"},
                  ["h"] = {41665, "MixerShowHideChildrenOfSelectedTrack"},
                  ["<tab>"] = {1042, "CycleFolderCollapsedState"},
                  ["F"] = {1041, "CycleTrackFolderState"}}},
      ["f"] = { "fx", {
                  ["id"] = {"_S&M_CLR_INFXCHAIN", "ClearFxChainInputCurrentTrack"},
                  ["d"] = {"_S&M_CLRFXCHAIN3", "ClearFxChainCurrentTrack"},
                  ["a"] = {"_S&M_CONSOLE_ADDFX", "FxAdd"},
                  ["p"] = {"_S&M_SMART_PST_FXCHAIN", "PasteFxChain"},
                  ["i"] = {40844, "ViewFxChainInputCurrentTrack"},
                  ["c"] = {"_S&M_TOGLFXCHAIN", "FxChainToggleShow"},
                  ["s"] = {"_S&M_WNTGL5", "FxToggleShowAll"},
                  ["S"] = {"_S&M_WNCLS5", "FxCloseSel"},
                  ["n"] = {"_S&M_WNONLY2", "FxShowNextSel"},
                  ["p"] = {"_S&M_WNONLY1", "FxShowPrevSel"},
                  ["N"] = {"_S&M_WNONLY1", "FxShowPrevSel"},
                  ["b"] = {8, "TrackToggleFXBypass"},
                  ["1"] = {"_S&M_TOGLFLOATFX1", "FxToggleShow1"},
                  ["2"] = {"_S&M_TOGLFLOATFX2", "FxToggleShow2"},
                  ["3"] = {"_S&M_TOGLFLOATFX3", "FxToggleShow3"},
                  ["4"] = {"_S&M_TOGLFLOATFX4", "FxToggleShow4"},
                  ["5"] = {"_S&M_TOGLFLOATFX5", "FxToggleShow5"},
                  ["6"] = {"_S&M_TOGLFLOATFX6", "FxToggleShow6"},
                  ["7"] = {"_S&M_TOGLFLOATFX7", "FxToggleShow7"},
                  ["8"] = {"_S&M_TOGLFLOATFX8", "FxToggleShow8"},
      }},
                  ["g"] = { "global", {
                              ["r"] = {40251, "ShowRoutingMatrix"},
                              ["w"] = {42031, "ShowWiringDiagram"},
                              ["c"] = {"_S&M_WNCLS3", "FxCloseAll"},
                              ["fS"] = {"_S&M_WNCLS3", "FxCloseAll"},
                              ["dr"] = {{41175, 42348}, "ResetAllMidiDevices, ResetAllMidiControlSurfaceDevices"},
                    ["tm"] = {40906, "ShowTrackManager"},
                    ["ts"] = {40340, "UnsoloAllTracks"},
                    ["tm"] = {40339, "UnmuteAllTracks"},
                    ["fc"] = {40846, "ViewFxChainMaster"},
                    ["a"] = {40491, "ClearAllRecordArm"},
                    [","] = {40016, "Preferences"},
                    ["e"] = {1155, "CycleRippleEditMode"},
                    ["S"] = {1157, "SnapToggle"},
                    ["m"] = {40364, "ToggleMetronome"},
                    ["ss"] = {41152, "ToggleShowAllEnvelopeGlobal"},
                    ["se"] = {40070, "ToggleEnvelopePointsMoveWithItems"},
                    ["sr"] = {40878, "GlobalSetTrackAutomationMode_TrimRead"},
                    ["sg"] = {40881, "GlobalSetTrackAutomationMode_Latch"},
                    ["sG"] = {42022, "GlobalSetTrackAutomationMode_LatchPreview"},
                    ["sl"] = {40881, "GlobalSetTrackAutomationMode_Latch"},
                    ["sL"] = {42022, "GlobalSetTrackAutomationMode_LatchPreview"},
                    ["sR"] = {40879, "GlobalSetTrackAutomationMode_Read"},
                    ["st"] = {40880, "GlobalSetTrackAutomationMode_Touch"},
                    ["sw"] = {40882, "GlobalSetTrackAutomationMode_Write"},
                    ["sS"] = {40876, "GlobalSetTrackAutomationMode_Off"},
                  }},
      ["a"] = { "arming", {
                  ["t"] = {9, "ArmToggleSelected"},
                  ["i"] = {40496, "SetTrackRecordMode_Input"},
                  ["o"] = {40500, "SetTrackRecordMode_MidiOutput"},
                  ["d"] = {40503, "SetTrackRecordMode_MidiOverdub"},
                  ["t"] = {40852, "SetTrackRecordMode_MidiTouchReplace"},
                  ["r"] = {40504, "SetTrackRecordMode_MidiReplace"},
                  ["m"] = {40498, "SetTrackRecordMode_MonitorOnly"},
                  -- shortcuts for one hand
                  ["f"] = {40496, "SetTrackRecordMode_Input"},
                  ["v"] = {40498, "SetTrackRecordMode_MonitorOnly"},
            }},
      ["e"] = { "envelopes", {
                  ["s"] = {41151, "ToggleShowAllEnvelope"},
                  ["h"] = {40884, "ToggleShowEnvelope"},
                  ["v"] = {40406, "ToggleVolumeEnvelope"},
                  ["p"] = {40407, "TogglePanEnvelope"},
                  ["d"] = {40333, "DelSelEnvelope"},
                  ["c"] = {40065, "ClearEnvelope"},
                  ["C"] = {"_S&M_REMOVE_ALLENVS", "ClearAllEnvelope"},
                  ["y"] = {40035, "CopySelEnvelope"},
                  ["a"] = {"_S&M_TGLARMALLENVS", "ToggleArmAllEnvelope"},
                  ["A"] = {40863, "ToggleArmEnvelope"},
                  ["r"] = {40400, "SetTrackAutomationMode_TrimRead"},
                  ["R"] = {40401, "SetTrackAutomationMode_Read"},
                  ["G"] = {42023, "SetTrackAutomationMode_LatchPreview"},
                  ["g"] = {40404, "SetTrackAutomationMode_Latch"},
                  ["L"] = {42023, "SetTrackAutomationMode_LatchPreview"},
                  ["l"] = {40404, "SetTrackAutomationMode_Latch"},
                  ["t"] = {40402, "SetTrackAutomationMode_Touch"},
                  ["w"] = {40403, "SetTrackAutomationMode_Write"},
            }},
      ["r"] = { "region", {
                  ["s"] = {
                    41039,
                    "SetLoopPointsToItem"
                  },
            }},
      ["p"] = { "project", {
                ["pr"] = { "render", {
                             ["."] = {41824, "RenderProjectWithLastSetting"},
                             ["r"] = {40015, "RenderProject"},
                        }},
                ["n"] = {40861, "NextTab"},
                ["p"] = {40862, "PrevTab"},
                ["s"] = {40026, "SaveProject"},
                ["o"] = {40025, "OpenProject"},
                ["c"] = {40859, "NewProjectTab"},
                ["d"] = {40860, "CloseProject"},
                ["x"] = {40098, "CleanProjectDirectory"},
            }},
    }},
  },
  motions = {
    G = {{"_XENAKIOS_TVPAGEEND", 40296, "_XENAKIOS_SELLASTOFSELTRAX"} ,"TrackViewEnd, SelectAllTracks, SelectLastOfSelectedTracks" },
    ["g"] = {{"_XENAKIOS_TVPAGEHOME", 40296, "_XENAKIOS_SELFIRSTOFSELTRAX"} , "TrackViewStart, SelectAllTracks, SelectFirstOfSelectedTracks" },
    B = {
      40790,
      "PrevBigItem"
    },
    E = {
      65535,
      "MoveToEndOfBigItem"
    },
    J = {
      "_SWS_SELNEARESTNEXTFOLDER",
      "NextFolderNear"
    },
    K = {
      "_SWS_SELNEARESTPREVFOLDER",
      "PrevFolderNear"
    },
    W = {
      40791,
      "NextBigItem"
    },
    b = {
      40416,
      "PrevItem"
    },
    e = {
      41174,
      "MoveToEndOfItem"
    },
    j = {
      40285,
      "NextTrack"
    },
    k = {
      40286,
      "PrevTrack"
    },
    ["<ctrl>b"] = {
      40286,
      "PrevTrack",
      times = 10
    },
    ["<ctrl>d"] = {
      40285,
      "NextTrack",
      times = 5
    },
    w = {
      40417,
      "NextItem"
    }
  },
  operators = {}
}
