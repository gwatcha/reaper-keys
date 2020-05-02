local command = {}

local executor = require("command.executor")

command.buildCommand = require("command.builder")
command.getPossibleFutureEntries = require("command.completer")
command.executeCommand = executor.executeCommand
command.executeMacroCommands = executor.executeMacroCommands

return command
