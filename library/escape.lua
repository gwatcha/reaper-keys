local info = debug.getinfo(1,'S');
local root_path = info.source:match[[[^@]*reaper.keys/]]
package.path = package.path .. ";" .. root_path .. "?.lua"

state_definitions = require('internal.state_machine.definitions')
state_interface = require('internal.state_machine.state_interface')
state_interface.set(state_definitions['reset_state'])
