local ru = require('custom_actions.utils')
local log = require('utils.log')
local str_util = require('utils.string')
local tr_util = require('utils.track')
local rc = require('definitions.routing')
local df = rc.default_params

local rlib_targets = require('library.route.rlib_targets')

local rlib_string = {}

local USER_INPUT_TARGETS_DIV = '|'

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
    local dataBracketSplit = str_util.getStringSplitPattern(dataBracket, sep)
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

function rlib_string.extractParamsFromString(rp, str)
  if str:find('%-') then
    rp.remove_routes = true
    rp.remove_both = true
  end
  if str:find('%#') then
    rp.category = 0
    rp.remove_both = false
  end
  if str:find('%$') then
    rp.category = -1
    rp.remove_both = false
  end

  -- HANDLE PARENTHESIS
  local ret, src_tr_data, dst_tr_data, str = extractParenthesisTargets(str)



  if src_tr_data ~= nil then -- SRC PROVIDED
    local src_tr_split =  str_util.getStringSplitPattern(src_tr_data, USER_INPUT_TARGETS_DIV)
    local ret, rp = rlib_targets.setRouteTargetGuids(rp, 'src_guids', src_tr_split)
  elseif tr_util.isSel() then -- FALLBACK SRC SEL
    -- rp.src_from_selection = true
    rp['src_guids'] = ru.getSelectedTracksGUIDs()
  end


  if dst_tr_data ~= nil then
    local dst_tr_split =  str_util.getStringSplitPattern(dst_tr_data, USER_INPUT_TARGETS_DIV)

    -- log.user('dest: ' .. format.block(dst_tr_split))

    local ret, rp = rlib_targets.setRouteTargetGuids(rp, 'dst_guids', dst_tr_split)
  end

  -- rp = assignGUIDsFromUserInput(rp, src_tr_data, dst_tr_data)


  -- A. HANDLE PRIMARY COMMANDS

  str, bSrc, bDst = getEnclosedChannelData(str, '[]', '|', 0, 6)

  str, cSrc, cDst = getEnclosedChannelData(str, '{}', '|', 0, 16)

  -- B. HANDLE SECONDARY PARAMS

  rp, str = handleSecondaryParams(rp, str, 'a', bSrc)

  rp, str = handleSecondaryParams(rp, str, 'd', bDst)

  local midi_flags
  if cSrc ~= nil and cDst ~= nil then midi_flags = midi_util.create_send_flags(cSrc,cDst) end
  -- log.user(cSrc, cDst, midi_flags)
  rp, str = handleSecondaryParams(rp, str, 'm', midi_flags)

  ret, val, pre = inputHasChar(str, 'u')
  if ret then rp.overwrite = true end

  return true, rp
end


return rlib_string
