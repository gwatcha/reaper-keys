local rc = require('definitions.routing')
local df = rc.default_params

local rlib_state = {}

function rlib_state.getPrevRouteState(rp, src_tr, dest_tr)
  local cat = rp.category
  local check_other = 1
  if rp.category == -1 then check_other = 0 end
  rp.prev = 0

  local num_routes_by_cat = reaper.GetTrackNumSends( src_tr, cat )

  for si=0,  num_routes_by_cat do
    local dest_tr_check = reaper.BR_GetMediaTrackSendInfo_Track( src_tr, cat, si, check_other )

    if dest_tr_check == dest_tr then
      -- log.user('prev match!!!!!')
      local prev_src_midi_flags = reaper.GetTrackSendInfo_Value(src_tr, cat, si, 'I_MIDIFLAGS')
      local prev_src_audio_ch = reaper.GetTrackSendInfo_Value(src_tr, cat, si, 'I_SRCCHAN')
      -- local prev_src_hw = reaper.GetTrackSendInfo_Value(src_tr, 1, si, 'I_SRCCHAN')
      local retval = 3 -- both audio and midi
      rp.prev = 3
      local no_midi = prev_src_midi_flags == rc.flags.MIDI_OFF
      local no_audio = prev_src_audio_ch ==  rc.flags.AUDIO_SRC_OFF
      -- only audio = 1
      if no_midi then rp.prev = 1 end
      -- only midi = 2
      if no_audio then rp.prev = 2 end
      return rp, si
    end
  end
  return rp
end


-- this function has to be improved.

function rlib_state.getNextRouteState(rp, check_str)

  local a_present = false
  local m_present = false
  local audio_off = false
  local midi_off = false
  if rp.new_params['a'] ~= nil then
    a_present = true

    if rp.new_params['a'].param_value == rc.flags.AUDIO_SRC_OFF then
      audio_off = true
    end
  end
  if rp.new_params['m'] ~= nil then
    m_present = true
    if rp.new_params['m'].param_value == rc.flags.MIDI_OFF then
       midi_off = true
    end
  end

  -- ONLY AUDIO //////////////////////////////

  if (not a_present and not m_present) or (a_present and not m_present) and not audio_off then

    rp.next = 1
    rp.new_params['m'] = {
      description = df['m'].description,
      param_name = df['m'].param_name,
      param_value = rc.flags.MIDI_OFF,
    }

  -- ONLY MIDI ///////////////////////////
  elseif not a_present and m_present and not midi_off or (audio_off and m_present) then
    rp.next = 2

    rp.new_params['a'] = {
      description = df['a'].description,
      param_name = df['a'].param_name,
      param_value = rc.flags.AUDIO_SRC_OFF,
    }

    -- BOTH ///////////////////////////////
    --
    -- it feels as if this is wrong but i don't remember
  elseif rp.new_params['a'] == nil and rp.new_params['m'] ~= nil then
    rp.next = 3 -- add both
  end
  return rp -- we should never arrive here i think since default always is add audio send
end

return rlib_state
