' Command 3C0 - 3DF
' 20200309
'
3C0:
   Civ_cmd4 = &H54
   Gosub Civ_print4_1a0502
Return
'
3C1:
   B_temp1 = 3
   Civ_cmd4 = &H55
   Gosub Civ_print_l_5_1a0502
Return
'
3C2:
   Civ_cmd4 = &H55
   Gosub Civ_print4_1a0502
Return
'
3C3:
   B_temp1 = 2
   Civ_cmd4 = &H56
   Gosub Civ_print_l_5_1a0502
Return
'
3C4:
   Civ_cmd4 = &H56
   Gosub Civ_print4_1a0502
Return
'
3C5:
   B_temp1 = 2
   Civ_cmd4 = &H57
   Gosub Tx_position_data
Return
'
3C6:
   Civ_cmd4 = &H57
   Gosub Civ_print4_1a0502
Return
'
3C7:
   B_temp1 = 3
   Civ_cmd4 = &H58
   Gosub Civ_print_l_5_1a0502
Return
'
3C8:
   Civ_cmd4 = &H58
   Gosub Civ_print4_1a0502
Return
'
3C9:
   B_temp1 = 57
   Temps_b(4) = &H59
   Gosub Send_text
Return
'
3CA:
   Civ_cmd4 = &H59
   Gosub Civ_print4_1a0502
Return
'
3CB:
   B_temp1 = 4
   Civ_cmd4 = &H60
   Gosub Civ_print_l_5_1a0502
Return
'
3CC:
   Civ_cmd4 = &H60
   Gosub Civ_print4_1a0502
Return
'
3CD:
   B_temp1 = 5
   Civ_cmd4 = &H61
   Gosub Civ_print_l_5_1a0502
Return
'
3CE:
   Civ_cmd4 = &H61
   Gosub Civ_print4_1a0502
Return
'
3CF:
   B_temp1 = 2
   Temps_b(3) = &H62
   Gosub Send_text
Return
'
3D0:
   Civ_cmd4 = &H62
   Gosub Civ_print4_1a0502
Return
'
3D1:
   B_temp1 = 2
   Temps_b(4) = &H63
   Gosub Send_text
Return
'
3D2:
   Civ_cmd4 = &H63
   Gosub Civ_print4_1a0502
Return
'
3D3:
   B_temp1 = 2
   Temps_b(4) = &H64
   Gosub Send_text
Return
'
3D4:
   Civ_cmd4 = &H64
   Gosub Civ_print4_1a0502
Return
'
3D5:
   B_temp1 = 2
   Temps_b(4) = &H65
   Gosub Send_text
Return
'
3D6:
   Civ_cmd4 = &H65
   Gosub Civ_print4_1a0502
Return
'
3D7:
   B_temp1 = 43
   Civ_cmd4 = &H66
   Gosub Civ_print_l_5_1a0502
Return
'
3D8:
   Civ_cmd4 = &H66
   Gosub Civ_print4_1a0502
Return
'
3D9:
   B_temp1 = 4
   Civ_cmd4 = &H67
   Gosub Civ_print_l_5_1a0502
Return
'
3DA:
   Civ_cmd4 = &H67
   Gosub Civ_print4_1a0502
Return
'
3DB:
   B_temp1 =44
   Temps_b(4) = &H68
   Gosub Send_text
Return
'
3DC:
   Civ_cmd4 = &H68
   Gosub Civ_print4_1a0502
Return
'
3DD:
   B_temp1 =44
   Temps_b(4) = &H69
   Gosub Send_text
Return
'
3DE:
   Temps_b(3) = &H69
   Gosub Civ_print4_1a0502
Return
'
3DF:
   B_temp1 = 44
   Temps_b(4) = &H70
   Gosub Send_text
Return
'