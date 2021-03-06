-- dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")
local log = require('utils.log')

local fx_util = {}


local REC_FX = 0x1000000

--[[-------------------------------


retval, minval, maxval = reaper.TrackFX_GetParam(track, fx_idx, param_idx)

retval, buf = reaper.TrackFX_GetParamName(track, fx_idx, param_idx, string buf)

----------------------------------

integer reaper.TrackFX_GetRecCount(track)

  To access record input FX, use a FX indices
  [0x1000000..0x1000000+n). On the master track, this accesses monitoring FX
  rather than record input FX.

---------------------------------

reaper.TrackFX_CopyToTrack(src_track, src_fx, dest_track, dest_fx, is_move)

  Copies (or moves) FX from src_track to dest_track.

  Can be used with src_track=dest_track to reorder, FX indices have 0x1000000 set
  to reference input FX.

-----------------------------------]]--



-- add ability to add last fx index
function fx_util.insertFxAtIndex(tr, fx_str, fx_insertTo_idx, is_rec_fx)
  local is_move_flag = true -- required on order to reorder tracks
  if is_rec_fx then
    reaper.TrackFX_AddByName(tr, fx_str, true, -1) -- add to last index
    local fx_idx_last = reaper.TrackFX_GetRecCount(tr) - 1
    if fx_idx_last ~= fx_insertTo_idx then
      reaper.TrackFX_CopyToTrack(
        tr,
        REC_FX + fx_idx_last,
        tr,
        REC_FX + fx_insertTo_idx,
        is_move_flag)
    end
  else
    reaper.TrackFX_AddByName(tr, fx_str, false, -1) -- add to last index
    local fx_idx_last = reaper.TrackFX_GetCount(tr) - 1
    if fx_idx_last ~= fx_insertTo_idx then
      reaper.TrackFX_CopyToTrack(tr, fx_idx_last, tr, fx_insertTo_idx, is_move_flag)
    end
  end
end

function fx_util.replaceFxAtIndex(tr, fx_str, fx_insertTo_idx, is_rec_fx)

  if is_rec_fx then
    removeFxAtIndex(tr, fx_insertTo_idx, true)
    insertFxAtIndex(tr, fx_str, fx_insertTo_idx, true)
  else
    removeFxAtIndex(tr, fx_insertTo_idx)
    insertFxAtIndex(tr, fx_str, fx_insertTo_idx)
  end
end

function fx_util.removeFxAtIndex(tr, fx_rm_idx, is_rec_fx)
  if is_rec_fx then
    reaper.TrackFX_Delete(tr, REC_FX + fx_rm_idx)
  else
    reaper.TrackFX_Delete(tr, fx_rm_idx)
  end
end

function fx_util.removeAllFXAfterIndex(tr, index)
  local tc = reaper.TrackFX_GetCount(tr)
  local num_fx_after_i = tc - index
  while(num_fx_after_i > 0 ) do
    for i = index, tc - 1 do
      reaper.TrackFX_Delete(tr, i)
    end
    tc = reaper.TrackFX_GetCount(tr)
    num_fx_after_i = tc - index
  end
end

function fx_util.setParamForFxAtIndex(tr, fx_idx, param, value, is_rec_fx)
  if is_rec_fx then
      reaper.TrackFX_SetParam(tr, REC_FX + fx_idx, param, value)
  else
      reaper.TrackFX_SetParam(tr, fx_idx, param, value)
  end
end

function fx_util.getSetTrackFxNameByFxChainIndex(tr,idx_fx,is_rec_fx, newName)
  local strT, found, slot = {}
  local Pcall
  local FXGUID

  if is_rec_fx then
    Pcall,FXGUID = pcall(reaper.TrackFX_GetFXGUID, tr, REC_FX + idx_fx)
  else
    Pcall,FXGUID = pcall(reaper.TrackFX_GetFXGUID, tr, idx_fx)
  end

  if not Pcall or not FXGUID then return false end
  local retval, str = reaper.GetTrackStateChunk(tr,"",false)
  local trFxNameStr

  -- https://lua.programmingpedia.net/en/tutorial/5829/pattern-matching
  for l in (str.."\n"):gmatch(".-\n") do
    table.insert(strT,l) -- add each line to table
  end

  for i = #strT,1,-1 do
    if strT[i]:match(FXGUID:gsub("%p","%%%0")) then
      found = true
    end
    if strT[i]:match("^<") and found and not strT[i]:match("JS_SER") then
      found = nil
      local nStr = {}
      for S in strT[i]:gmatch("%S+") do
        if not X then
          nStr[#nStr+1] = S
        else
          nStr[#nStr] = nStr[#nStr].." "..S
        end
        if S:match('"') and not S:match('""')and not S:match('".-"') then
          if not X then
            X = true
          else
            X = nil
          end
        end
      end
      if strT[i]:match("^<%s-JS") then
        slot = 3
      elseif strT[i]:match("^<%s-AU")
        then
        slot = 4
      elseif strT[i]:match("^<%s-VST") then
        slot = 5
      end
      if not slot then error("Failed to rename/access name",2)
      end
      trFxNameStr = nStr[slot]
      if newName ~= nil and type(newName) == 'string' then
        nStr[slot] = newName:gsub(newName:gsub("%p","%%%0"),'"%0"')
      end
      nStr[#nStr+1]="\n"
      strT[i] = table.concat(nStr," ")
      break
    end
  end

  if newName ~= nil and type(newName) == 'string' then
    return reaper.SetTrackStateChunk(tr, table.concat(strT), false)
  end
  return trFxNameStr
end

function fx_util.bypassFX()
end

return fx_util
