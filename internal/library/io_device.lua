local reaper_utils = require('custom_actions.utils')
local log = require('utils.log')
local format = require('utils.format')
local io = require('definitions.io')

local io_device = {}

-- TODO
--
-- how check if device is present
-- alert user gui
--
-- on reaper init
-- setup devices

function captureNewIODevices()
  -- capture and write newly recognized devices to persenal config list??
end

function setMidiInForSingleTrack(tr, chan, dev_name)
  log.clear()

  if not tr then return end
  if not chan then chan = 0 end
  if not dev_name then dev_name = io.midi.vkb end
  for i = 0, 64 do
    local retval, nameout = reaper.GetMIDIInputName( i, '' )
    if nameout ~= '' then log.user(nameout) end
    if nameout:lower():match(dev_name:lower()) then dev_id = i end
  end

  if not dev_id then return end -- log.user('device not found')
  val = 4096+ chan + ( dev_id << 5  )
  reaper.SetMediaTrackInfo_Value( tr, 'I_RECINPUT',val)
end

function setMidiInMultSel(dev_name)
  for i = 1, reaper.CountSelectedTracks(0) do
    local tr = reaper.GetSelectedTrack(0,i-1)
    setMidiInForSingleTrack( tr, channel, dev_name )
  end
end

-- would it be possible to pass arguments to actions in definitions/
-- if so refactor into one fn here
function io_device.setInputTo_MIDI_DEFAULT() setMidiInMultSel() end
function io_device.setInputTo_MIDI_VIRTUAL() setMidiInMultSel(io.midi.vkb) end
function io_device.setInputTo_MIDI_QMK() setMidiInMultSel(io.midi.qmk) end
function io_device.setInputTo_MIDI_GRAND_ROLAND() setMidiInMultSel(io.midi.roland) end

return io_device
