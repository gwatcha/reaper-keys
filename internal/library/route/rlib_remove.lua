local ru = require('custom_actions.utils')
local log = require('utils.log')
local rc = require('definitions.routing')

local rlib_remove = {}

function rlib_remove.deleteRouteIfEmpty(src_tr, rid)
  local i_src_ch = reaper.GetTrackSendInfo_Value(src_tr, 0, rid, 'I_SRCCHAN')
  local i_src_midi = reaper.GetTrackSendInfo_Value(src_tr, 0, rid, 'I_MIDIFLAGS')
  if i_src_ch == rc.flags.AUDIO_SRC_OFF and i_src_midi == rc.flags.MIDI_OFF then
    log.user('::delete send ' .. rid .. '::')
    rlib_remove.removeSingle(src_tr, 0, rid)
  end
end

function rlib_remove.removeSingle(tr, cat, sendidx)
  local ret = reaper.RemoveTrackSend(tr, cat, sendidx)
end

function deleteByCategory(tr, cat)
  local num_cat_sends = reaper.GetTrackNumSends(tr, cat)
  -- if num_cat_sends == 0 then return end
  while(num_cat_sends > 0) do
    for si=0, num_cat_sends-1 do
      local rm = reaper.RemoveTrackSend(tr, cat, si)
    end
    num_cat_sends = reaper.GetTrackNumSends(tr, cat)
  end
end

function rlib_remove.removeAllRoutesTrack(rp)
  for i = 1, #rp.src_guids do
    local tr, tr_idx = ru.getTrackByGUID(rp.src_guids[i].guid)
    if not rp.remove_both and rp.category == 0 then
      deleteByCategory(tr, rc.flags.CAT_SEND)
    elseif not rp.remove_both and rp.category == -1 then
      deleteByCategory(tr, rc.flags.CAT_REC)
    elseif rp.remove_both then
      deleteByCategory(tr, rc.flags.CAT_SEND)
      deleteByCategory(tr, rc.flags.CAT_REC)
    end -- if
  end -- for
  return true
end

return rlib_remove
