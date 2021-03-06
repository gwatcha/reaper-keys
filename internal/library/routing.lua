local ru = require('custom_actions.utils')
local log = require('utils.log')
local format = require('utils.format')
local config = require('definitions.config')
local rc = require('definitions.routing')
local df = rc.default_params

local routing = {}

local input_placeholder = "" -- "(176)aR" -- used for testing purps

-- I was trying format the text box but I did not get it to work
local route_help_str = "route params:\n" .. "\nk int  = category" .. "\ni int  = send idx"
local div = '\n##########################################\n\n'
local div2 = '---------------------------------'

local USER_INPUT_TARGETS_DIV = '|'

--
--      REAPER BUG
--
--        create ticket on forum
--        upon writing a lot of send funcs I find that CreateTrackSend(track, nil)
--          creates a wierd kind of hwout that i have to remove manually.
--          it does not show up when logging route states
--          no error!!!!!!!!!!!!!!!!!!!!
--
--      TODO
--
--
--      inform user about feedback points
--        make it easy to manage feedback routes safely
--          list all feedback points
--            i need to learn gui asap
--
--
--      NUDGE VALUES
--
--      nudge volume
--      nudge pan
--
--      TOGGLE PARAMS
--
--      - mono / stereo
--      - mute
--      - flip phase

--  PUBLIC | move to custom.lua ???

-- func for testing that coded targets are working.
-- ie. using routing.updateState within code instead
-- of using it in-app.
function routing.testCodedTargets()
  log.user('test coded targets')
  local guid_src = getMatchedTrackGUIDs('TEST_A')
  local guid_dst = getMatchedTrackGUIDs('TEST_B')

  log.user(format.block(guid_src[1]))
  -- log.user(guid_src)

  routing.create('[0|2]R', guid_src[#guid_src].guid, guid_dst[#guid_dst].guid)
end


function routing.updateState(route_str, coded_sources, coded_dests)
  -- log.clear()
  local rp = rc
  local _

  -- !!!!
  --  I set remove_routes explicitly here. Why?
  --    Because on my second laptop this prop gets converted
  --    to true even though i never set it to true. I don't understad why.
  --    This is really wierd. Anyways, luckilly it works by setting it here
  rp.remove_routes = false

  if route_str == nil then
    rp.user_input = true
    _, route_str = reaper.GetUserInputs("ENTER ROUTE STRING:", 1, route_help_str, input_placeholder)
  end

  local ret
  ret, rp = extractParamsFromString(rp, route_str)
  if not ret then return end -- something went wrong

  if coded_sources ~= nil then
    rp.coded_targets = true
    ret, rp = setRouteTargetGuids(rp, 'src_guids', coded_sources)
  end
  if coded_dests ~= nil then
    rp.coded_targets = true
    ret, rp = setRouteTargetGuids(rp, 'dst_guids', coded_dests)
  end

  if rp.remove_routes then
    handleRemoval(rp)
  elseif not rp.user_input then
    targetLoop(rp)
  elseif confirmRouteCreation(rp) then
    targetLoop(rp)
  else
    log.clear()
    log.user('<ROUTE COMMAND ABORTED>')
  end
end

-- refactor these into one with variable arguments
function routing.removeAllSends(tr) removeAllRoutesTrack(tr) end
function routing.removeAllRecieves(tr) removeAllRoutesTrack(tr, 1) end
function routing.removeAllBoth(tr) removeAllRoutesTrack(tr, 2) end

-- refactor and put back to log
function routing.logRoutingInfoForSelectedTracks()
  -- log.clear()
  local log_t = ru.getSelectedTracksGUIDs()

  for i = 1, #log_t do
    local tr, tr_idx = ru.getTrackByGUID(log_t[i].guid)
    local _, current_name = reaper.GetTrackName(tr)

    log.user('\n'..div..'\n:: routes for track #' .. tr_idx+1 .. ' `' .. current_name .. '`:')
    log.user('\n\tSENDs:')
    logRoutesByCategory(tr, rc.flags.CAT_SEND)
    log.user('\tRECIEVEs:')
    logRoutesByCategory(tr, rc.flags.CAT_REC)
    log.user('\tHARDWARE:')
    logRoutesByCategory(tr, rc.flags.CAT_HW)
  end
end

function lrp(r)
  log.user(div, format.block(r))
end

--  UTILS | mv to reaper util?

function isSel() return reaper.CountSelectedTracks(0) ~= 0 end

function TableConcat(t1,t2)
  for i=1,#t2 do
    t1[ #t1+1 ] = t2[i]  --corrected bug. if t1[#t1+i] is used, indices will be skipped
  end
  return t1
end

-- TODO
--
-- retval, t ?
function getMatchedTrackGUIDs(search_name)
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

-- TODO
--
-- this function alse is defined in syntax/syntax
--
-- mv to util
function getStringSplitPattern(pString, pPattern)
  local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
  local fpat = "(.-)" .. pPattern
  local last_end = 1
  local s, e, cap = pString:find(fpat, 1)
  while s do
    if s ~= 1 or cap ~= "" then
      table.insert(Table,cap)
    end
    last_end = e+1
    s, e, cap = pString:find(fpat, last_end)
  end
  if last_end <= #pString then
    cap = pString:sub(last_end)
    table.insert(Table, cap)
  end
  return Table
end

--  TODO
--
--  mv to midi.util
--
--  MIDI FLAGS | move to midi utils ???

--  GET FIRST 5 BITS
function get_send_flags_src(flags) return flags & ((1 << 5)- 1) end

--  GET SECOND 5 BITS
function get_send_flags_dest(flags) return flags >> 5 end

--  GET SRC AND DEST BYTE PREPARED
function create_send_flags(src_ch, dest_ch) return (dest_ch << 5) | src_ch end

--  ROUTE STATE LOGGING

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

function logRoutesByCategory(tr, cat)
  local num_cat_sends = reaper.GetTrackNumSends(tr, cat)
  if num_cat_sends == 0 then return end
  for si = 0, num_cat_sends-1 do
    if cat <= 0 then -- REGULAR SENDS ////////////////////////////////////////////
      local other_tr, other_tr_idx = getOtherTrack(tr, cat, si)
      local _, other_tr_name = reaper.GetTrackName(other_tr)
      local SRC = reaper.GetTrackSendInfo_Value(tr, cat, si, 'I_SRCCHAN')
      local DST = reaper.GetTrackSendInfo_Value(tr, cat, si, 'I_DSTCHAN')
      local mf = reaper.GetTrackSendInfo_Value(tr, cat, si, 'I_MIDIFLAGS')
      local mfs = get_send_flags_src(mf)
      local mfd = get_send_flags_dest(mf)
      log.user(string.format("\t\t(#%i) `%s` >> %i :: %i -> %i | %i -> %i",
        other_tr_idx+1, other_tr_name, si, SRC, DST, mfs, mfd))
    elseif cat > 0 then -- HARDWARE /////////////////////////////////////
    end
  end
end

--  EXTRACT ROUTE PARAMS

function logConfirmList(rp)
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

function logHeader(str)
  log.user(div, str .. '\n\n')
end

function confirmRouteCreation(rp)
  -- LOG FINAL SOURCES TARGETS
  local num_tr_affected = #rp.src_guids*#rp.dst_guids

  local warning_str = 'Tot num routes being affected = '.. num_tr_affected
  local r_u_sure = 'Confirm update routes'
  logHeader(warning_str)
  -- log.user(div, warning_str)

  logConfirmList(rp)

  local help_str = "` #src: `" .. tostring(#rp.src_guids) ..
  "` #dst: `" .. tostring(#rp.dst_guids) .. "` (y/n)"

  if num_tr_affected > rc.tot_route_num_limit and not rp.coded_targets then
    _, answer = reaper.GetUserInputs(r_u_sure, 1, help_str, "")
  end

  if answer == "y" then return true end
  return false
end


--    key = src_guid/dst_guids
--    new_track_data = (tr / tr_guid / tr_name / table)
function setRouteTargetGuids(rp, key, new_tracks_data)
  local retval = false
  local log_str = 'new_tracks_data >>> '
  local tr_guids = {}
  -- log.user(key, format.block(type(new_tracks_data)))
  if type(new_tracks_data) ~= 'table' then -- NOT TABLE ::::::::::::::
    if new_tracks_data == '<not_working_yet>' then
      -- track
    elseif ru.getTrackByGUID(new_tracks_data) ~= false then
      retval = true
      local tr, tr_idx = ru.getTrackByGUID(new_tracks_data)
      local _, current_name = reaper.GetTrackName(tr)
      tr_guids = {{ name = current_name, guid = new_tracks_data }}
    else
      retval = false
      log.user('new tracks data NOT table but did not pass as TRACK/GUID')
    end

  else -- TABLE :::::::::::::::::::::::::::::::::::::::::::::::::::::
    retval = true
    for i = 1, #new_tracks_data do
      if new_tracks_data == '<not_working_yet>' then
        --
      elseif ru.getTrackByGUID(new_tracks_data[i]) ~= false then
        local tr, tr_idx = ru.getTrackByGUID(new_tracks_data[i])
        local _, current_name = reaper.GetTrackName(tr)
        tr_guids[i] = { name = current_name, guid = new_tracks_data[i] }

      elseif tonumber(new_tracks_data[i]) ~= nil then
        local tr = reaper.GetTrack(0, tonumber(new_tracks_data[i]) - 1)
        local _, current_name = reaper.GetTrackName(tr)

        local guid_from_tr = ru.getGUIDByTrack(tr)
        tr_guids[i] = { name = current_name, guid = guid_from_tr }
      else
        local match_t = getMatchedTrackGUIDs(new_tracks_data[i])
        local tr_guids = TableConcat(tr_guids, match_t)
      end
    end -- for
  end -- table

  if retval then rp[key] = tr_guids end
  return retval, rp
end

function removeEnclosureFromString(str, encl_type)
  for r in str:gmatch ("%b"..encl_type) do
    str = str:gsub("%("..r.."%)", "")
  end
  return str
end

function extractParenthesisTargets(str)
  local pcount = 0
  for p in str:gmatch "%b()" do
    pcount = pcount + 1
    if pcount == 1 then pDest = str.sub(p, 2, str.len(p) - 1) end
    if pcount == 2 then
      pSrc = pDest
      pDest = str.sub(p, 2, str.len(p) - 1)
      break
    end
  end
  str = removeEnclosureFromString(str, '()')
  return retval, pSrc, pDest, str
end

function getEnclosers(str, encl)
  local data
  for p in str:gmatch ("%b"..encl) do
    data = str.sub(p, 2, str.len(p) - 1)
  end
  str = removeEnclosureFromString(str, encl)
  return data, str
end

function inputHasChar(str, key)
  local pattern = "!?" .. key .. "%d?%.?%d?%d?%d?%d?" -- very generic pattern
  local s, e = string.find(str, pattern)
  local mv_offset = 1
  local retval = false
  local matched_value
  local prefix

  if s ~= nil and e ~= nil then
    retval = true
    local sub_pattern = string.sub(str,s,e)
    prefix = string.sub(sub_pattern,0,1)
    if prefix == '!' then mv_offset = 2 end
    matched_value = string.sub(str,s+mv_offset,e)
  end

  return retval, matched_value, prefix
end


function getEnclosedChannelData(str, encloser, sep, rangeL, rangeH)
  local dataBracket, str = getEnclosers(str, encloser)
  local bSrc, bDst
  if dataBracket ~= nil then
    local dataBracketSplit = getStringSplitPattern(dataBracket, sep)
    for d=1, #dataBracketSplit do
      local D = tonumber(dataBracketSplit[d])
      if D < rangeL or D > rangeH then D = 0 end
      if d==1 then if D ~= nil then bDst = D else bDst = 0 end end
      if d==2 then
        bSrc = bDst
        if D ~= nil then bDst = D else bDst = 0 end
        break
      end
    end
  end
  return str, bSrc, bDst
end

function handleSecondaryParams(rp, str, key, primary)
  local ret, val, pre = inputHasChar(str, key)
  -- log.user(key, ret, val, pre)

  -- exists or PRIMARY
  if ret or primary ~= nil then

    if primary ~= nil then val = primary else val = tonumber(val) end

    if ret and val == nil then val = df[key].param_value end

    rp.new_params[key] = {
      description = df[key].description,
      param_name = df[key].param_name,
      param_value = val,
    }

    -- exists and prefix
    if ret and pre == '!' then rp.new_params[key].param_value = df[key].disable_value end
  end

  return rp, str
end

function extractParamsFromString(rp, str)
  if str:find('%-') then
    rp.remove_routes = true
    rp.remove_both = true
  end
  if str:find('S') then
    rp.category = 0
    rp.remove_both = false
  end
  if str:find('R') then
    rp.category = -1
    rp.remove_both = false
  end

  -- HANDLE PARENTHESIS
  local ret, src_tr_data, dst_tr_data, str = extractParenthesisTargets(str)



  if src_tr_data ~= nil then -- SRC PROVIDED
    local src_tr_split =  getStringSplitPattern(src_tr_data, USER_INPUT_TARGETS_DIV)
    local ret, rp = setRouteTargetGuids(rp, 'src_guids', src_tr_split)
  elseif isSel() then -- FALLBACK SRC SEL
    -- rp.src_from_selection = true
    rp['src_guids'] = ru.getSelectedTracksGUIDs()
  end


  if dst_tr_data ~= nil then
    local dst_tr_split =  getStringSplitPattern(dst_tr_data, USER_INPUT_TARGETS_DIV)
    local ret, rp = setRouteTargetGuids(rp, 'dst_guids', dst_tr_split)
  end

  -- rp = assignGUIDsFromUserInput(rp, src_tr_data, dst_tr_data)


  -- A. HANDLE PRIMARY COMMANDS

  str, bSrc, bDst = getEnclosedChannelData(str, '[]', '|', 0, 6)

  str, cSrc, cDst = getEnclosedChannelData(str, '{}', '|', 0, 16)

  -- B. HANDLE SECONDARY PARAMS

  rp, str = handleSecondaryParams(rp, str, 'a', bSrc)

  rp, str = handleSecondaryParams(rp, str, 'd', bDst)

  local midi_flags
  if cSrc ~= nil and cDst ~= nil then midi_flags = create_send_flags(cSrc,cDst) end
  -- log.user(cSrc, cDst, midi_flags)
  rp, str = handleSecondaryParams(rp, str, 'm', midi_flags)

  ret, val, pre = inputHasChar(str, 'u')
  if ret then rp.overwrite = true end

  return true, rp
end

--  GET ROUTE STATE

function getPrevRouteState(rp, src_tr, dest_tr)
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

function getNextRouteState(rp, check_str)
  if (rp.new_params['a'] == nil and rp.new_params['m'] == nil) or
    (rp.new_params['a'] ~= nil and rp.new_params['m'] == nil)
    and rp.new_params['a'].param_value ~= rc.flags.AUDIO_SRC_OFF then

    rp.next = 1
    rp.new_params['m'] = {
      description = df['m'].description,
      param_name = df['m'].param_name,
      param_value = rc.flags.MIDI_OFF,
    }

  elseif rp.new_params['a'] == nil and rp.new_params['m'] ~= nil
    and rp.new_params['m'].param_value ~= rc.flags.MIDI_OFF or
    (rp.new_params['a'].param_value == rc.flags.AUDIO_SRC_OFF and rp.new_params['m'] ~= nil) then
    rp.next = 2

    rp.new_params['a'] = {
      description = df['a'].description,
      param_name = df['a'].param_name,
      param_value = rc.flags.AUDIO_SRC_OFF,
    }
  elseif rp.new_params['a'] == nil and rp.new_params['m'] ~= nil then
    rp.next = 3 -- add both
  end
  return rp -- we should never arrive here i think since default always is add audio send
end

--  REMOVE ROUTES

function handleRemoval(rp)
  if #rp.src_guids == 0 then
    log.user('REMOVAL ERROR > NO SOURCE TARGETS SPECIFIED')

  elseif #rp.dst_guids == 0 then
    -- logHeader('REMOVE ALL ROUTES ON BASE')
    -- logConfirmList(rp)
    removeAllRoutesTrack(rp) -- 2 == both send/rec

  else
    -- logHeader('src rm > connections btw list src/dst')
    -- logConfirmList(rp)
    targetLoop(rp)

  end
end

function deleteRouteIfEmpty(src_tr, rid)
  local i_src_ch = reaper.GetTrackSendInfo_Value(src_tr, 0, rid, 'I_SRCCHAN')
  local i_src_midi = reaper.GetTrackSendInfo_Value(src_tr, 0, rid, 'I_MIDIFLAGS')
  if i_src_ch == rc.flags.AUDIO_SRC_OFF and i_src_midi == rc.flags.MIDI_OFF then
    log.user('::delete send ' .. rid .. '::')
    removeSingle(src_tr, 0, rid)
  end
end

function removeSingle(tr, cat, sendidx)
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

function removeAllRoutesTrack(rp)
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

--  UPDATE ROUTE STATE

function targetLoop(rp)
  -- log.user('target')
  for i = 1, #rp.src_guids do
    for j = 1, #rp.dst_guids do
      local rid
      if rp.src_guids[i].guid == rp.dst_guids[j].guid then goto continue end

      local src_tr, sidx = ru.getTrackByGUID(rp.src_guids[i].guid)
      local dst_tr, didx = ru.getTrackByGUID(rp.dst_guids[j].guid)

      rp, rid = getPrevRouteState(rp, src_tr, dst_tr)
      rp      = getNextRouteState(rp)

      if rp.remove_routes then
        if rid == nil then
          -- log.user('TR: ' .. rp.src_guids[i].name .. ' has no sends..')
          return false
        end
        -- log.user('TR: ' .. rp.src_guids[i].name .. ' , rm send id: ' .. rid)
        removeSingle(src_tr, rp.category, rid)
      else
        if rp.prev == 0 then
          if rp.category == rc.flags.CAT_SEND then
            -- log.user('ROUTE #'.. sidx+1 ..' `'.. rp.src_guids[i].name ..'`  -->  #'.. didx+1 ..' `'.. rp.dst_guids[j].name .. '`')
            rid = reaper.CreateTrackSend(src_tr, dst_tr)
          elseif rp.category == rc.flags.CAT_REC then
            -- log.user('ROUTE #'.. sidx+1 ..' `'.. rp.src_guids[i].name ..'`  <--  #'.. didx+1 ..' `'.. rp.dst_guids[j].name .. '`')
            rid = reaper.CreateTrackSend(dst_tr,src_tr)
          end
        end

        if rp.category == rc.flags.CAT_SEND then
          updateRouteState_Track(src_tr, rp, rid)
        elseif rp.category == rc.flags.CAT_REC then
          updateRouteState_Track(dst_tr, rp, rid)
        end

        deleteRouteIfEmpty(src_tr, rid)
      end
      :: continue ::
    end -- dst
  end -- src
end

function updateRouteState_Track(src_tr, rp, rid)
  -- log.user(format.block(rp))
  -- HANDLE MONO ?!?!
  -- if dest_tr_ch == 2 then
  --   reaper.SetTrackSendInfo_Value( src_tr, 0, new_rid, 'I_SRCCHAN',0)
  -- else
  --   reaper.SetTrackSendInfo_Value( src_tr, 0, new_rid, 'I_SRCCHAN',0|(1024*math.floor(src_tr_ch/2)))
  -- end
  --
  -- log.user(src_tr)

  -- lrp(rp)
  -- local test =  reaper.GetTrackSendInfo_Value( src_tr, rp.category, rid, 'I_SRCCHAN')
  -- log.user('test' .. test)

  local _, current_name = reaper.GetTrackName(src_tr)
    -- log.user('update tr: ' .. current_name)

  for k, p in pairs(rp.new_params) do
    if k == 'm' then

      -- skipp if previous route component exists and not overwrite flag
      if (rp.prev == 2 or rp.prev == 3) and not rp.overwrite then goto continue end

      -- next is only audio and first
      if rp.next == 1 and rp.prev ~= 0 then goto continue end

      reaper.SetTrackSendInfo_Value(src_tr, 0, rid, p.param_name, p.param_value)
    else

      -- skipp if previous route component exists and not overwrite flag
      if (rp.prev == 1 or rp.prev == 3) and not rp.overwrite then goto continue end

      -- next is only midi and first
      if rp.next == 2 and rp.prev ~= 0 then goto continue end

      reaper.SetTrackSendInfo_Value(src_tr, 0, rid, p.param_name, p.param_value)
    end

    :: continue ::
  end
end

--  OTHER

-- why did this one come from hmmm
-- function incrementDestChanToSrc(dest_tr, src_tr_ch)
--   local dest_tr_ch = reaper.GetMediaTrackInfo_Value( dest_tr, 'I_NCHAN')
--   if dest_tr_ch < src_tr_ch then reaper.SetMediaTrackInfo_Value( dest_tr, 'I_NCHAN', src_tr_ch ) end
--   return dest_tr_ch
-- end

function preventRouteFeedback()
  -- ??????
end

------------------------------------------------------------------------

return routing
