local clearLog = reaper.ClearConsole
local bindingsPath = reaper.GetResourcePath() .. '/vimper_bindings.lua'
local timeOut = 2

function tryTriggerAction(actions, curInput, count)
  actionFun = actions[curInput]
  if actionFun then
    local ret = actionFun(count)
    return ret or true
  else
    return false
  end
end

function timeoutState()
  local curTime = os.time()
  local lastTime = getLastTime() or 0
  updateLastTime(curTime)
  if curTime - lastTime >= timeOut then
    clearQuery()
  end
end

function longestTableKeyLen(t)
  local longestLen = 0
  for k,_ in pairs(t) do
    local l = string.len(k)
    if l > longestLen then
      longestLen = l
    end
  end
  return longestLen
end


-- Replaces all instances of special keys, e.g <space>, with a single character
function shortenSpecial(str)
  return string.gsub(str, '<.->', '_')
end


function mapTableKeys(t, f)
  local out = {}
  for k, v in pairs(t) do
    local newK = f(k, v)
    out[newK] = v
  end

  return out
end


function shortenKeys(t)
  return mapTableKeys(t, function(k)
    return shortenSpecial(k)
  end)
end


function stripNumbers(str)
  return str:gsub("[1-9]?[0-9]*(.-)$", "%1")
end


function getCount(str)
  local count = 0
  local firstNonNumInd = str:find("[^%d]")
  if firstNonNumInd ~= nil and firstNonNumInd > 1 then
    for d in str:sub(0, firstNonNumInd-1):gmatch '%d' do
      count = count*10 + tonumber(d)
    end
  end
  return count
end

function tooLong(actions, query)
  return longestTableKeyLen(shortenKeys(actions)) <= string.len(shortenSpecial(query))
end

function appendKey(channel, context)
  timeoutState()
  local state = getQuery() or ''
  local allActions = mergeInclude(scriptPath()..'actions.lua', bindingsPath)

  local actions = allActions.global
  for k,v in pairs(allActions[context]) do actions[k] = v end

  local originalQuery = state .. channel
  local curCount = getCount(shortenSpecial(originalQuery))
  local query =  stripNumbers(originalQuery)
  log(query .. " | " .. channel)

  local actionRet = tryTriggerAction(actions, query, curCount)

  log(context)

  if actionRet and actionRet ~= DO_NOT_STORE_LAST then
    setLastAction(originalQuery)
    setLastContext(context)
  end

  if channel == "<esc>" or actionRet or tooLong(actions, query) then
    log 'clearQuery'
    clearQuery()
  else
    updateQuery(channel)
  end
end
