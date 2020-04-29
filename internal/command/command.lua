local command = {}

command.buildCommand = require("command.builder")
command.executeCommand = require("command.executor")
command.getPossibleFutureEntries = require("command.completer")

return command
