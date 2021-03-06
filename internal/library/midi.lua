local log = require('utils.log')
local format = require('utils.format')


-- // MIDI HELPER VARIABLE
-- WAS_FILTERED = 1024;  // array for storing which notes are filtered
-- PASS_THRU_CC = 0;

local MODE = 0

-- TYPE_MASK=0xF0;
-- CHANNEL_MASK=0x0F;
-- //OMNI=0x00;
local NOTE_ON   = 0x90
local NOTE_OFF  = 0x80
local VEL       = 0x50 -- dec 80
-- //IN_GM=0x00;
-- //ORPHAN_KILL=0x00;
-- //ORPHAN_REMAP=0x01;
-- //OUT_AD=0x00;
-- //OUT_BFD=0x01;
-- //OUT_SD=0x02;

local midi = {}

function midi.sendMidiNote_A_2() sendMidiNote(57) end
function midi.sendMidiNote_Gs2() sendMidiNote(56) end
function midi.sendMidiNote_G_2() sendMidiNote(55) end
function midi.sendMidiNote_Fs2() sendMidiNote(54) end
function midi.sendMidiNote_F_2() sendMidiNote(53) end
function midi.sendMidiNote_E_2() sendMidiNote(52) end
function midi.sendMidiNote_Ds2() sendMidiNote(51) end
function midi.sendMidiNote_D_2() sendMidiNote(50) end
function midi.sendMidiNote_Cs2() sendMidiNote(49) end
function midi.sendMidiNote_C_2() sendMidiNote(48) end


--  TODO
--
--    how can I use key-release here??
--      write an issue > ask Mike about this

function sendMidiNote(note_num)
  reaper.StuffMIDIMessage( MODE,  NOTE_ON,  note_num,  VEL)
  -- wait()
  reaper.StuffMIDIMessage( MODE,  NOTE_OFF,  note_num,  VEL)
end


local easy_read = [[
\*\ eaper.StuffMIDIMessage(integer mode, integer msg1, integer msg2, integer msg3)

  Stuffs a 3 byte MIDI message into either the Virtual MIDI Keyboard queue, or
  the MIDI-as-control input queue, or sends to a MIDI hardware output.  mode=0
  for VKB, 1 for control (actions map etc), 2 for VKB-on-current-channel; 16
  for external MIDI device 0, 17 for external MIDI device 1, etc; see
  GetNumMIDIOutputs, GetMIDIOutputName.

\*\ integer reaper.GetNumMIDIOutputs()

  returns max number of real midi hardware outputs

\*\ boolean retval, string nameout = reaper.GetMIDIOutputName(integer dev, string nameout)

  returns true if device present
]]


return midi

