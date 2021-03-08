local track = {}

function track.isSel() return reaper.CountSelectedTracks(0) ~= 0 end

function track.getMatchedTrackGUIDs(search_name)
  if not search_name then return nil end
  local found = false
  local t = {}
  for i=0, reaper.CountTracks(0) - 1 do
    local tr = reaper.GetTrack(0, i)
    local _, current_name = reaper.GetTrackName(tr)
    if current_name:match(search_name) then
      t[#t+1] = { name = current_name, guid = reaper.GetTrackGUID( tr ) }
      found = true
    end
  end
  if found then return t else return false end
end


return track
