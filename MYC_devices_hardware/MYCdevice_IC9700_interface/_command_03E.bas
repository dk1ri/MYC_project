' Command 3E0 - 3FF
' 20200309
'
3E0:
   Civ_cmd4 = &H70
   Gosub Civ_print4_1a0502
Return
'
3E1:
   B_temp1 = 44
   Temps_b(4) = &H71
   Gosub Send_text
Return
'
3E2:
   Civ_cmd4 = &H71
   Gosub Civ_print4_1a0502
Return
'
3E3:
   B_temp1 = 3
   Civ_cmd4 = &H72
   Gosub Civ_print_l_5_1a0502
Return
'
3E4:
   Civ_cmd4 = &H72
   Gosub Civ_print4_1a0502
Return
'
3E5:
   B_temp1 = 2
   Civ_cmd4 = &H73
   Gosub Tx_position_data
Return
'
3E6:
   Civ_cmd4 = &H73
   Gosub Civ_print4_1a0502
Return
'
3E7:
   B_temp1 = 3
   Civ_cmd4 = &H74
   Gosub Civ_print_l_5_1a0502
Return
'
3E8:
   Civ_cmd4 = &H74
   Gosub Civ_print4_1a0502
Return
'
3E9:
   B_temp1 = 10
   Civ_cmd4 = &H75
   Gosub Civ_print_l_5_1a0502
Return
'
3EA:
   Civ_cmd4 = &H75
   Gosub Civ_print4_1a0502
Return
'
3EB:
   B_temp1 = 10
   Civ_cmd4 = &H76
   Gosub Civ_print_l_5_1a0502
Return
'
3EC:
   Civ_cmd4 = &H76
   Gosub Civ_print4_1a0502
Return
'
3ED:
   B_temp1 = 10
   Civ_cmd4 = &H77
   Gosub Civ_print_l_5_1a0502
Return
'
3EE:
   Civ_cmd4 = &H77
   Gosub Civ_print4_1a0502
Return
'
3EF:
   B_temp1 = 9
   Temps_b(4) = &H78
   Gosub Send_text
Return
'
3F0:
   Civ_cmd4 = &H78
   Gosub Civ_print4_1a0502
Return
'
3F1:
   B_temp1 = 16
   Temps_b(4) = &H79
   Gosub Send_text
Return
'
3F2:
   Civ_cmd4 = &H79
   Gosub Civ_print4_1a0502
Return
'
3F3:
   B_temp1 = 2
   Temps_b(4) = &H80
   Gosub Send_text
Return
'
3F4:
   Civ_cmd4 = &H80
   Gosub Civ_print4_1a0502
Return
'
3F5:
   B_temp1 = 2
   Temps_b(4) = &H81
   Gosub Send_text
Return
'
3F6:
   Civ_cmd4 = &H81
   Gosub Civ_print4_1a0502
Return
'
3F7:
   B_temp1 = 2
   Temps_b(4) = &H82
   Gosub Send_text
Return
'
3F8:
   Civ_cmd4 = &H82
   Gosub Civ_print4_1a0502
Return
'
3F9:
   B_temp1 = 2
   Civ_cmd4 = &H83
   Gosub Tx_position_data
Return
'
3FA:
   Civ_cmd4 = &H83
   Gosub Civ_print4_1a0502
Return
'
3FB:
   B_temp1 = 3
   Civ_cmd4 = &H84
   Gosub Civ_print_l_5_1a0502
Return
'
3FC:
   Civ_cmd4 = &H84
   Gosub Civ_print4_1a0502
Return
'
3FD:
   W_temp1 = 361
   Civ_cmd4 = &H85
   Gosub Civ_print_2_2_bcd
Return
'
3FE:
   Civ_cmd4 = &H85
   Gosub Civ_print4_1a0502
Return
'
3FF:
   W_temp1 = 1851
   Civ_cmd4 = &H86
   Gosub Civ_print_2_2_bcd
Return
'