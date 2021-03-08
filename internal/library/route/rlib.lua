local ru = require('custom_actions.utils')
local log = require('utils.log')
local tr_util = require('utils.track')
local table_util = require('utils.track')
local midi_util = require('utils.midi')
local str_util = require('utils.string')
local format = require('utils.format')
local rc = require('definitions.routing')
local df = rc.default_params

local rlib_log = require('library.route.rlib_log')
local rlib_remove = require('library.route.rlib_remove')
local rlib_state = require('library.route.rlib_state')
local rlib_targets = require('library.route.rlib_targets')

local rlib = {}

local div = '\n##########################################\n\n'

function lrp(r)
  log.user(div, format.block(r))
end

function rlib.confirmRouteCreation(rp)
  local num_tr_affected = #rp.src_guids*#rp.dst_guids

  if num_tr_affected >= rc.tot_route_num_limit and not rp.coded_targets then
    local warning_str = 'Tot num routes being affected = '.. num_tr_affected
    local r_u_sure = 'Confirm update routes'
    local help_str = "` #src: `" .. tostring(#rp.src_guids) ..
    "` #dst: `" .. tostring(#rp.dst_guids) .. "` (y/n)"
    logHeader(warning_str)
    -- log.user(div, warning_str)
    rlib_log.logConfirmList(rp)
    local _, answer = reaper.GetUserInputs(r_u_sure, 1, help_str, "")
    if answer == "y" then return true end
    return false
  end
  return true
end

function rlib.handleRemoval(rp)
  if #rp.src_guids == 0 then
    log.user('REMOVAL ERROR > NO SOURCE TARGETS SPECIFIED')

  elseif #rp.dst_guids == 0 then
    -- logHeader('REMOVE ALL ROUTES ON BASE')
    -- logConfirmList(rp)
    rlib_remove.removeAllRoutesTrack(rp) -- 2 == both send/rec

  else
    -- logHeader('src rm > connections btw list src/dst')
    -- logConfirmList(rp)
    targetLoop(rp)

  end
end

--  UPDATE ROUTE STATE

function rlib.targetLoop(rp)
  -- log.user('target')
  for i = 1, #rp.src_guids do
    for j = 1, #rp.dst_guids do
      local rid
      if rp.src_guids[i].guid == rp.dst_guids[j].guid then goto continue end

      local src_tr, sidx = ru.getTrackByGUID(rp.src_guids[i].guid)
      local dst_tr, didx = ru.getTrackByGUID(rp.dst_guids[j].guid)

      rp, rid = rlib_state.getPrevRouteState(rp, src_tr, dst_tr)
      rp      = rlib_state.getNextRouteState(rp)

      if rp.remove_routes then
        if rid == nil then
          -- log.user('TR: ' .. rp.src_guids[i].name .. ' has no sends..')
          return false
        end
        -- log.user('TR: ' .. rp.src_guids[i].name .. ' , rm send id: ' .. rid)
        rlib_remove.removeSingle(src_tr, rp.category, rid)
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

        rlib_remove.deleteRouteIfEmpty(src_tr, rid)
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
  -- lrp(rp)
end

--  OTHER

-- where did this one come from hmmm
-- function incrementDestChanToSrc(dest_tr, src_tr_ch)
--   local dest_tr_ch = reaper.GetMediaTrackInfo_Value( dest_tr, 'I_NCHAN')
--   if dest_tr_ch < src_tr_ch then reaper.SetMediaTrackInfo_Value( dest_tr, 'I_NCHAN', src_tr_ch ) end
--   return dest_tr_ch
-- end

function preventRouteFeedback()
  -- ??????
end

----------------------------------------------------------------------

return rlib
