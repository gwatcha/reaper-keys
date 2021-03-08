local midi = {}

--  GET FIRST 5 BITS
function midi.get_send_flags_src(flags) return flags & ((1 << 5)- 1) end

--  GET SECOND 5 BITS
function midi.get_send_flags_dest(flags) return flags >> 5 end

--  GET SRC AND DEST BYTE PREPARED
function midi.create_send_flags(src_ch, dest_ch) return (dest_ch << 5) | src_ch end

return midi
