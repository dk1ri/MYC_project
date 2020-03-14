' additional init
' 190722
'
Civ_adress = Civ_adress_eeram
Header = Header_
Header_b(3) = Civ_adress
Replayheader = Replay_header_
Replayheader_b(4) = Civ_adress
Ok_msg = Ok_msg_
Ok_msg_b(4) = Civ_adress
Nok_msg = Nok_msg_
Nok_msg_b(4) = Civ_adress
Gosub Civ_reset
Read_memory_counter = 0
Block_read_mem_command = 0
' sel
Memory_default_b(1) = &H01
' freq
Memory_default_b(2) = &H00
Memory_default_b(3) = &H00
Memory_default_b(4) = &H00
Memory_default_b(5) = &H14
Memory_default_b(6) = &H00
' mode filter
Memory_default_b(7) = &H00
Memory_default_b(8) = &H01
' Data
Memory_default_b(9) = &H00
' repeater tone freqeuncy
Memory_default_b(10) = &H00
Memory_default_b(11) = &H08
Memory_default_b(12) = &H85
' tone squelch freqeuncy
Memory_default_b(13) = &H00
Memory_default_b(14) = &H08
Memory_default_b(15) = &H85
' freuency split
Memory_default_b(16) = &H00
Memory_default_b(17) = &H00
Memory_default_b(18) = &H00
Memory_default_b(19) = &H14
Memory_default_b(20) = &H00
' mode filter
Memory_default_b(21) = &H00
Memory_default_b(22) = &H01
' Data
Memory_default_b(23) = &H00
' repeater tone frequency
Memory_default_b(24) = &H00
Memory_default_b(25) = &H08
Memory_default_b(26) = &H85
' tone squelch freqeuncy
Memory_default_b(27) = &H00
Memory_default_b(28) = &H08
Memory_default_b(29) = &H85
' name
Memory_default_b(30) = &H20
Memory_default_b(31) = &H20
Memory_default_b(32) = &H20
Memory_default_b(33) = &H20
Memory_default_b(34) = &H20
Memory_default_b(35) = &H20
Memory_default_b(36) = &H20
Memory_default_b(37) = &H20
Memory_default_b(38) = &H20
Memory_default_b(39) = &H20