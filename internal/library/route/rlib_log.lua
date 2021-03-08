local log = require('utils.log')
local midi_util = require('utils.midi')

local route_log = {}

-- this should be done w/ gui

function route_log.logHeader(str)
  log.user(div, str .. '\n\n')
end

function route_log.logRoutesByCategory(tr, cat)
  local num_cat_sends = reaper.GetTrackNumSends(tr, cat)
  if num_cat_sends == 0 then return end
  for si = 0, num_cat_sends-1 do
    if cat <= 0 then -- REGULAR SENDS ////////////////////////////////////////////
      local other_tr, other_tr_idx = getOtherTrack(tr, cat, si)
      local _, other_tr_name = reaper.GetTrackName(other_tr)
      local SRC = reaper.GetTrackSendInfo_Value(tr, cat, si, 'I_SRCCHAN')
      local DST = reaper.GetTrackSendInfo_Value(tr, cat, si, 'I_DSTCHAN')
      local mf = reaper.GetTrackSendInfo_Value(tr, cat, si, 'I_MIDIFLAGS')
      local mfs = midi_util.get_send_flags_src(mf)
      local mfd = midi_util.get_send_flags_dest(mf)
      log.user(string.format("\t\t(#%i) `%s` >> %i :: %i -> %i | %i -> %i",
        other_tr_idx+1, other_tr_name, si, SRC, DST, mfs, mfd))
    elseif cat > 0 then -- HARDWARE /////////////////////////////////////
    end
  end
end

function route_log.logConfirmList(rp)
  log.user('::: SOURCE TRACKS :::\n')
  for i = 1, #rp.src_guids do
    local tr, tr_idx = ru.getTrackByGUID(rp.src_guids[i].guid)
    local _, src_name = reaper.GetTrackName(tr)
    log.user('\t' .. tr_idx .. ' - ' .. src_name)
  end
  log.user('\n::: DESTINATION TRACKS :::\n')
  for i = 1, #rp.dst_guids do
    local tr, tr_idx = ru.getTrackByGUID(rp.dst_guids[i].guid)
    local _, dst_name = reaper.GetTrackName(tr)
    log.user('\t' .. tr_idx .. ' - ' .. dst_name)
  end
  log.user('\n>>> CONFIRM ROUTE CREATION (y<Enter> -> confirm)\n\n')
end

-- hardware doesn't work ?!
function getOtherTrack(tr, cat, si)
  local other_tr
  if cat == 0 then
    other_tr = reaper.BR_GetMediaTrackSendInfo_Track(tr, cat, si, 1)
  else
    other_tr = reaper.BR_GetMediaTrackSendInfo_Track(tr, cat, si, 0)
  end
  local other_tr_idx = reaper.GetMediaTrackInfo_Value(other_tr, "IP_TRACKNUMBER") - 1
  return other_tr, other_tr_idx
end

return route_log
