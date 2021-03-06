local reaper_utils = require('custom_actions.utils')
local log = require('utils.log')
local format = require('utils.format')

io_device = {}


-- TODO
--
-- device not present
--  gui >> device not present!
--
--


local my_devices = {
  -- how could I put and manage used devices in nice list config?
}

-- todo
function captureNewIODevices()
  -- 1. capture and write to file
  --    2. write these into config list somehow
end



--  REAPER STARTUP
--
--    on start up look for midi devices / audio devices and
--    enable the ones I prefer

function setMidiInForSingleTrack(tr, chan, dev_name)
  log.clear()
  if not tr then return end
  if not chan then chan = 0 end
  if not dev_name then dev_name = 'Virtual Midi Keyboard' end -- config.default_midi_device
  for i = 0, 64 do
    local retval, nameout = reaper.GetMIDIInputName( i, '' )
    -- if nameout ~= '' then log.user(nameout) end
    if nameout:lower():match(dev_name:lower()) then
      log.user('found: ' .. nameout)
      dev_id = i
    end
  end

  if not dev_id then
    -- log.user('device not found')
    return
  end

  val = 4096+ chan + ( dev_id << 5  )

  reaper.SetMediaTrackInfo_Value( tr, 'I_RECINPUT',val)
end

function setMidiInMultSel(dev_name)
  for i = 1, reaper.CountSelectedTracks(0) do
    local tr = reaper.GetSelectedTrack(0,i-1)
    setMidiInForSingleTrack( tr, channel, dev_name )
  end
end

function io_device.setInputTo_MIDI_DEFAULT() setMidiInMultSel() end

-- move these funcs to config >> ./personal/io_devices.lua ???
function io_device.setInputTo_MIDI_VIRTUAL() setMidiInMultSel('Virtual Midi Keyboard') end

function io_device.setInputTo_MIDI_QMK() setMidiInMultSel('Ergodox EZ') end

--[[
--  TODO
--
--    `Roland - RD Series - Port 1` why is this not working??
--
--    whenever I use a new piano (88) keys >> add to list of pianos? maybe good idea
--        easy to recal settings for piano size when in studio
--]]
local roland_escaped = 'Roland %- RD Series %- Port 1'
function io_device.setInputTo_MIDI_GRAND_ROLAND() setMidiInMultSel(roland_escaped) end

return io_device
