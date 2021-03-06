-- move all of these down into rc config
--
-- or should these be put in routing lib?
local TRACK_INFO_AUDIO_SRC_DISABLED = -1
local TRACK_INFO_MIDIFLAGS_ALL_CH = 0
local TRACK_INFO_MIDIFLAGS_DISABLED = 4177951
local TRACK_INFO_CATEGORY_SEND = 0 -- send
local TRACK_INFO_CATEGORY_RECIEVE = -1 -- send
local TRACK_INFO_CATEGORY_HARDWARE = 1 -- send

--//////////////////////////////////////////////////
--
-- ROUTING
--
--  neither of a and m | a and not m
--      create AUDIO send (default)
--
--  only m
--      create midi send
--
--  a and m
--      create both audio and m
--
--  ----------------------------
--
--  the param_name is not necessarily the input format ?!
--
--  ----------------------------
--  prepend key with `!` to update w/ disable value
--
--  `()u!a` = disablu audio for track ()
--
--  ----------------------------
--  EXAMPLES
--
--  (176)               only audio send from sel to #176
--
--  (176)(50)a          only audio send from #176 to #50
--
--  (nameA)(nameB){2}   midi send from tr_nameA ch 0 to tr_nameV B ch 2
--
--  (nameB)[0|2]{}
--        midi send from tr_nameA ch 0 to tr_nameV B ch 2
--
--
--
--
--//////////////////////////////////////////////////

return {

  --  /////////////////////////////////////////////////////////////////////
  --  ROUTING MACROS
  --  ////////////////
  --
  --  TODO
  --
  --  - auto send (SRC_PATTERN) to (DEST_PATTERN)


  macros = {
    ['X'] = '(<dest_tr_name>)a2!m'
  },

  -- SET : always work with tables in the end
  -- GET : for loop
  --
  src_guids = {},
  dst_guids = {},
  -- src_from_str = false,
  -- src_from_sel = false,
  dst_from_str = false,
  user_input = false,

  coded_targets = false,

  -- code_tot_route_num_limit = 5,
  tot_route_num_limit = 5,
  route_num_extreme = 20,
  remove_routes = false,


  -- 0 send, 1 rec, 2 both (remove..)
  -- you cannot create with `2`
  category = 0,


  --  /////////////////////////////////////////////////////////////////////
  --  FLAGS
  --  ///////


  flags = {
    AUDIO_SRC_OFF = TRACK_INFO_AUDIO_SRC_DISABLED,
    MIDI_ALL_CH = TRACK_INFO_MIDIFLAGS_ALL_CH,
    MIDI_OFF = TRACK_INFO_MIDIFLAGS_DISABLED,
    CAT_SEND = TRACK_INFO_CATEGORY_SEND,
    CAT_REC = TRACK_INFO_CATEGORY_RECIEVE,
    CAT_HW = 1,
  },

  -- ////////////////////////////////////////////////////////////////////
  -- PARAMS
  -- ////////////
  -- remove `param_` >>> becomes redundant

  new_params = {--[[ empty ]]},

  default_params = {
    -- ////////////////////////////////////////////////////////////////////
    -- WHICH TYPE
    -- ////////////

    ["a"] = {
      description = 'SOURCE CHAN | int, index, &1024=mono, -1 for none',
      param_name = 'I_SRCCHAN',
      param_value = 0,
      disable_value = TRACK_INFO_AUDIO_SRC_DISABLED
    },
    ["m"] = {
      description = 'CREATE MIDI SEND | self ch / dest ch (default = ALL)',
      param_name = 'I_MIDIFLAGS',
      param_value = TRACK_INFO_MIDIFLAGS_ALL_CH,
      disable_value = TRACK_INFO_MIDIFLAGS_DISABLED
    },
    ["d"] = {
      description = 'DEST CHAN | int, index, &1024=mono, -1 for none',
      param_name = 'I_DSTCHAN',
      param_value = 0,
    },

    -- /////////////////////////////////////////////////////////////////////////////
    -- SEND MODE
    -- ///////////

    -- ["s"] = {
    --   description = 'SENDMODE | int, 0=post-fader, 1=pre-fx, 2=post-fx (deprecated), 3=post-fx',
    --   param_name = 'I_SENDMODE',
    --   param_value = 3
    -- },

    -- commented >>> always default to send
    -- ["k"] = {
    --   description = 'route type | int, is <0 for receives, 0=sends, >0 for hardware outputs',
    --   param_name = 'CATEGORY',
    --   param_value = 0,
    -- },

    -- ////////////////////////////////////////////////////////////////////////////////
    -- NUDGE PARAMS
    -- //////////////
    --
    --    0 = do nothing
    --    + = nudge
    --
    --    TODO this would require a dedicated match-pattern

    -- ["v"] = {
    --   description = 'VOLUME | TODO.. double, 1.0 = +0dB',
    --   param_name = 'D_VOL',
    --   param_value = 1
    -- },
    -- ["P"] = {
    --  description = 'update pan | -+int (max/min) (default=0)'
    --   param_name = 'D_PAN',
    --   param_value = 0, -- double,   -1..+1
    -- },

    -- //////////////////////////////////////////////////////////////////////////////////
    -- TOGGLES
    -- /////////
    --  > you don't have to submit params
    --
    --  > 1 = flip

    -- [""] = {
    --   param_name = 'SEND_IDX',
    --   param_value = 0,
    -- }, -- send_idx    : int
    -- ["M"] = {
    --   param_name = 'B_MUTE',
    --   param_value = 0, -- bool
    -- },
    -- ["p"] = {
    --  description = 'flip phase (p)'
    --   param_name = 'B_PHASE',
    --   param_value = 0, -- bool
    -- },
    -- ["n"] = {
    --    description = 'TOGGLE MONO/STEREO'
    --   param_name = 'B_MONO',
    --   param_value = 0, -- bool
    -- },
    -- ["P"] = {
    --   param_name = 'D_PANLAW',
    --   param_value = 0, -- double,   1.0=+0.0db, 0.5=-6dB, -1.0 = projdef etc
    -- },
    -- ["a"] = {
    --   param_name = 'I_AUTOMODE',
    --   param_value = 0, -- int :     auto mode (-1=use track automode, 0=trim/off, 1=read, 2=touch, 3=write, 4=latch)
    -- },
  }
}

-- boolean reaper.SetTrackSendInfo_Value(MediaTrack tr, integer category, integer sendidx, string parmname, number newvalue)
--
-- Set send/receive/hardware output numerical-value attributes, return true on success.
-- category is <0 for receives, 0=sends, >0 for hardware outputs
-- parameter names:
-- B_MUTE : bool *
-- B_PHASE : bool *, true to flip phase
-- B_MONO : bool *
-- D_VOL : double *, 1.0 = +0dB etc
-- D_PAN : double *, -1..+1
-- D_PANLAW : double *,1.0=+0.0db, 0.5=-6dB, -1.0 = projdef etc
-- I_SENDMODE : int *, 0=post-fader, 1=pre-fx, 2=post-fx (deprecated), 3=post-fx
-- I_AUTOMODE : int * : automation mode (-1=use track automode, 0=trim/off, 1=read, 2=touch, 3=write, 4=latch)
-- I_SRCCHAN : int *, index,&1024=mono, -1 for none
-- I_DSTCHAN : int *, index, &1024=mono, otherwise stereo pair, hwout:&512=rearoute
-- I_MIDIFLAGS : int *, low 5 bits=source channel 0=all, 1-16, next 5 bits=dest channel, 0=orig, 1-16=chanSee CreateTrackSend, RemoveTrackSend, GetTrackNumSends.


-- number reaper.GetTrackSendInfo_Value(MediaTrack tr, integer category, sendidx, parmname)
--
-- Get send/receive/hardware output numerical-value attributes.
-- category is <0 for receives, 0=sends, >0 for hardware outputs
-- parameter names:
-- B_MUTE : bool *
-- B_PHASE : bool *, true to flip phase
-- B_MONO : bool *
-- D_VOL : double *, 1.0 = +0dB etc
-- D_PAN : double *, -1..+1
-- D_PANLAW : double *,1.0=+0.0db, 0.5=-6dB, -1.0 = projdef etc
-- I_SENDMODE : int *, 0=post-fader, 1=pre-fx, 2=post-fx (deprecated), 3=post-fx
-- I_AUTOMODE : int * : automation mode (-1=use track automode, 0=trim/off, 1=read, 2=touch, 3=write, 4=latch)
-- I_SRCCHAN : int *, index,&1024=mono, -1 for none
-- I_DSTCHAN : int *, index, &1024=mono, otherwise stereo pair, hwout:&512=rearoute
-- I_MIDIFLAGS : int *, low 5 bits=source channel 0=all, 1-16, next 5 bits=dest channel, 0=orig, 1-16=chanP_DESTTRACK : read only, returns MediaTrack *, destination track, only applies for sends/recvs
-- P_SRCTRACK : read only, returns MediaTrack *, source track, only applies for sends/recvs
-- P_ENV:<envchunkname : read only, returns TrackEnvelope *. Call with :<VOLENV, :<PANENV, etc appended.


-- MediaTrack reaper.BR_GetMediaTrackSendInfo_Track(MediaTrack track, integer category, integer sendidx, integer trackType)
--
-- [BR] Get source or destination media track for send/receive.
--
-- category is <0 for receives, 0=sends
-- sendidx is zero-based (see GetTrackNumSends to count track sends/receives)
-- trackType determines which track is returned (0=source track, 1=destination track)
