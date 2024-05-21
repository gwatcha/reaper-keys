-- @module Message

local Message = {}

--- Prints arguments to the Reaper console. Each argument is sanitized with
-- `tostring`, and the string is ended by a line break.
-- @param ... any
Message.Msg = function (...)
  local out = {}
  for _, v in ipairs({...}) do
    out[#out+1] = tostring(v)
  end
  reaper.ShowConsoleMsg(table.concat(out, ", ").."\n")
end

local queuedMessages = {}

--- Queues arguments for printing as a bulk message. This can be useful for scripts
-- with a lot of console output, as Reaper's performance can be impacted by printing
-- to the console too often. Arguments are sanitized with `tostring`.
-- @param ... any
Message.queueMsg = function (...)
  local out = {}
  for _, v in ipairs({...}) do
    out[#out+1] = tostring(v)
  end
  queuedMessages[#queuedMessages+1] = table.concat(out, ", ")
end

--- Prints all stored messages and clears the queue
Message.printQueue = function()
  reaper.ShowConsoleMsg(table.concat(queuedMessages, "\n").."\n")
  queuedMessages = {}
end

return Message
