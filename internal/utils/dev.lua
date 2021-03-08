
local dev = {}

function dev.logLastTouchedFxParams()
  local retval, tracknumber, itemnumber, fxnumber = reaper.GetFocusedFX()

  -- no fx window
  if retval == 0 then
    reaper.MB("No FX has focus...", "Nothing to list, sorry!", 0)
    return reaper.defer(function() end)
  end

  local track = reaper.CSurf_TrackFromID( tracknumber, false )
  reaper.ClearConsole()

  -- track FX
  if retval == 1 then
    local parm_cnt = reaper.TrackFX_GetNumParams( track, fxnumber )
    local _, name = reaper.TrackFX_GetFXName( track, fxnumber, "" )
    reaper.ShowConsoleMsg("\n" .. name .. " parameter id numbers\n\n")
    for i = 0, parm_cnt-1 do
      local retval, buf = reaper.TrackFX_GetParamName( track, fxnumber, i, "" )
      reaper.ShowConsoleMsg(i .. ": " .. buf .. "\n")
    end

    -- item FX
  elseif retval == 2 then
    local fxid = fxnumber >> 16 -- (FX Number)
    local takeid = fxnumber & 0xFFFF -- (Take Index)
    local item = reaper.GetMediaItem( 0, itemnumber )
    local take = reaper.GetMediaItemTake( item, takeid )
    local parm_cnt = reaper.TakeFX_GetNumParams( take, fxid )
    local _, name = reaper.TakeFX_GetFXName( take, fxid, "" )
    reaper.ShowConsoleMsg("\n" .. name .. " parameter id numbers\n\n")
    for i = 0, parm_cnt-1 do
      local retval, buf = reaper.TakeFX_GetParamName( take, fxid, i, "" )
      reaper.ShowConsoleMsg(i .. ": " .. buf .. "\n")
    end
  end
  reaper.defer(function() end)
end

function dev.logPaths()
end

return dev







