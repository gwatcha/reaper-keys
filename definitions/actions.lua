-- if you need to define a new action for use in reaper keys, do so here
-- if you need help check out the documentation https://gwatcha.github.io/reaper-keys/configuration/actions.html
-- see ./defaults/actions.lua for examples, as well as actions you can call

-- provides functions which are specific to reaper-keys, such as macros
-- search for 'lib' in the default actions file to see examples
local lib = require('library')
-- provides custom functions which make use of the reaper api
-- search for 'custom' in the default actions file to see examples
local custom = require('custom_actions')

-- naming conventions:
-- a noun implies an action which selects the noun, or a movement to it's position
-- simple verbs are usually operators, such as 'change'
-- longer verbs are usually commands

return {
}
