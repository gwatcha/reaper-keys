local log = require('utils.log')
local format = require('utils.format')

-- start, end = reaper.GetSet_LoopTimeRange(boolean isSet, boolean isLoop, number start, number end, boolean allowautoseek)


-- functions related to moving segments and sections of a song

local segments = {}

function segments.insertSpaceAtEditCursorFromTimeSelection()
  log.user('fn insert space')

  local tstart, tend = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)

  reaper.PreventUIRefresh(1)

  local curPos = reaper.GetCursorPosition()
  reaper.GetSet_LoopTimeRange(true, false, curPos, curPos + (tend - tstart), false)
  reaper.Main_OnCommand(40200, 0) -- Time selection: Insert empty space at time selection (moving later items)
  reaper.GetSet_LoopTimeRange(true, false, tstart, tend, false)

  reaper.PreventUIRefresh(-1)
end

-- TODO
--
-- get this to work now
function segments.repeatShiftAllItemsInTimeSelectionByTrackByTimeSel()
  log.user('---first---')
  -- 1. if item pos is before time sel start  skip
  -- 2. add time_sel_len
  local start_sel, end_sel = reaper.GetSet_LoopTimeRange(0, 0, 0, 0, 0)

  log.user("start", start_sel)
  log.user("end", end_sel)

  local data = {}
  if reaper.CountSelectedMediaItems(0) < 1 then return end

  data = collectMediaItemData(data)

  log.user('!!!!!!!!')

  local measure_shift, end_fullbeatsmax = CalcMeasureShift(data)
  local increment_measure = OverlapCheck(data, measure_shift, end_fullbeatsmax)

  DuplicateItems(data, end_sel - start_sel)
end

function collectMediaItemData(data)
  for i = 1, reaper.CountSelectedMediaItems(0) do

    local item = reaper.GetSelectedMediaItem( 0, i-1 )
    local pos = reaper.GetMediaItemInfo_Value( item, 'D_POSITION' )
    local len = reaper.GetMediaItemInfo_Value( item, 'D_LENGTH' )
    local GUID = reaper.BR_GetMediaItemGUID( item )

    local pos_beats_t = {reaper.TimeMap2_timeToBeats( 0, pos )}
    local end_beats_t = {reaper.TimeMap2_timeToBeats( 0, pos+len )}

    log.user('#######')

    data[i] = {src_tr =  reaper.GetMediaItem_Track( item ),
      chunk = ({reaper.GetItemStateChunk( item, '', false )})[2],
      group_ID = reaper.GetMediaItemInfo_Value( item, 'I_GROUPID'),
      col = reaper.GetMediaItemInfo_Value( item, 'I_CUSTOMCOLOR' ),
      start_t = pos,
      end_t = pos+len,
      pos_conv = {   pos_conv_beats = pos_beats_t [1],
        pos_conv_measure = pos_beats_t [2],
        pos_conv_fullbeats = pos_beats_t [4],
      },
      end_conv = {   end_conv_beats = end_beats_t [1],
        end_conv_measure = end_beats_t [2],
        end_conv_fullbeats = end_beats_t [4],
      },
      GUID = reaper.BR_GetMediaItemGUID( item )
    }

  end
  log.user(format.block(data))
  return data
end

function CalcMeasureShift(data)
  local meas_min = math.huge
  local meas_max = 0
  local end_fullbeatsmax = 0
  for i = 1, #data do
    meas_min = math.min(meas_min, data[i].pos_conv.pos_conv_measure)
    meas_max = math.max(meas_max, data[i].end_conv.end_conv_measure)
    end_fullbeatsmax = math.max(end_fullbeatsmax, data[i].end_conv.end_conv_fullbeats)
  end
  local measure_shift = math.max(1,meas_max - meas_min)
  return measure_shift, end_fullbeatsmax
end

function OverlapCheck(data, measure_shift, end_fullbeatsmax)
  reaper.ClearConsole()
  for i = 1, #data do
    local shifted_pos = reaper.TimeMap2_beatsToTime( 0, data[i].pos_conv.pos_conv_beats, data[i].pos_conv.pos_conv_measure + measure_shift )
    if shifted_pos < reaper.TimeMap2_beatsToTime( 0, end_fullbeatsmax ) then  return 1 end
  end
  return 0
end

function DuplicateItems(data,measure_shift)
  for i = 1, #data do
    local new_it = reaper.AddMediaItemToTrack( data[i].src_tr )
    reaper.SetItemStateChunk( new_it, data[i].chunk, false )


    log.user(
      '>>>',
      measure_shift,
      data[i].pos_conv.pos_conv_beats,
      data[i].pos_conv.pos_conv_measure,
      data[i].pos_conv.pos_conv_beats,
      data[i].end_conv.end_conv_measure
      )

    -- this works!!
    local new_pos = data[i].start_t + measure_shift
    local new_end = data[i].end_t + measure_shift

    -- i get wierd errors when i use below beat to time.
    -- log msg don't show and the error comes from after logs. hhmmm..
    --
    -- local new_pos = reaper.TimeMap2_beatsToTime( 0, data[i].pos_conv.pos_conv_beats, data[i].pos_conv.pos_conv_measure + measure_shift )
    -- local new_end = reaper.TimeMap2_beatsToTime( 0, data[i].pos_conv.pos_conv_beats, data[i].end_conv.end_conv_measure + measure_shift )
    -- local new_pos = reaper.TimeMap2_beatsToTime( 0, data[i].pos_conv.pos_conv_measure + measure_shift )
    -- local new_end = reaper.TimeMap2_beatsToTime( 0, data[i].end_conv.end_conv_measure + measure_shift )
    reaper.SetMediaItemInfo_Value( new_it, 'D_POSITION', new_pos)
    reaper.SetMediaItemInfo_Value( new_it, 'D_LENGTH', new_end - new_pos)
    --SetMediaItemInfo_Value( new_it, 'I_CUSTOMCOLOR', data[i].col )
  end
end

return segments
