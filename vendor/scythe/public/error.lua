--- @module Error

local Error = {}

--- Handles script errors, adding details such as a stack trace and Reaper/library
-- versions to the Lua error message. Any code called from within the Scythe GUI
-- loop is automatically wrapped with this, so the typical use-case would be
-- functions that are run prior to initializing the GUI, or after it closes.
--
-- Usage:
-- ```lua
-- xpcall(myFunction, Error.handleError)
-- ```
Error.handleError = function (errObject)
  -- Dump any queued messages, since they're probably relevant
  printQMsg()

  -- Global hook for any user functions to perform when an error is thrown
  if Error.onError then Error.onError(errObject) end

  local byLine = "([^\r\n]*)\r?\n?"
  local trimPath = "[\\/]([^\\/]-:%d+:.+)$"
  local err = errObject   and string.match(errObject, trimPath)
                          or  "Couldn't get error message."

  local trace = debug.traceback()
  local stack = {}
  for line in string.gmatch(trace, byLine) do

    local str = string.match(line, trimPath) or line

    stack[#stack + 1] = str
  end

  -- It's not really helpful to list this function in the stack trace
  table.remove(stack, 1)

  local name = ({reaper.get_action_context()})[2]:match("([^/\\_]+)$")

  if Scythe.args.printErrors or (
    reaper.ShowMessageBox(
      name.." has crashed!\n\n"..
      "Would you like to have a crash report printed "..
      "to the Reaper console?",
      "Oops",
      4
    ) == 6
  ) then
    reaper.ShowConsoleMsg(
      "Error: "..err.."\n\n"..
      "Stack traceback:\n\t"..table.concat(stack, "\n\t", 2).."\n\n"..
      "Scythe:      \t".. Scythe.version.."\n"..
      "Reaper:      \t"..reaper.GetAppVersion().."\n"..
      "Platform:    \t"..reaper.GetOS()
    )
  end

  Scythe.quit = true
end

-- Checks for Reaper's "restricted permissions" script mode and sets a relevant
-- error message in case the script tries to do something it can't.
if Scythe.scriptRestricted then

  Error.errorRestricted = function(t, key)

      -- luacheck: push ignore 631
      reaper.MB(  "This script tried to access a function that isn't available in Reaper's 'restricted permissions' mode." ..
                  "\n\nThe script was NOT necessarily doing something malicious - restricted scripts are unable " ..
                  "to execute many system-level tasks such as reading and writing files." ..
                  "\n\nPlease let the script's author know, or consider running the script without restrictions if you feel comfortable.",
                  "Script Error", 0)
      -- luacheck: pop

      error("Restricted permissions, unable to call " .. t .. "." .. key)

  end

  os = setmetatable({}, { __index = Error.errorRestricted }) -- luacheck: ignore 121
  io = setmetatable({}, { __index = Error.errorRestricted }) -- luacheck: ignore 121

end

return Error
