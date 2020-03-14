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
