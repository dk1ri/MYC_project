' Command 400 - 41F
' 20200310
'
400:
   Civ_cmd4 = &H85
   Gosub Civ_print4_1a0502
Return
'
401:
   W_temp1 = 10
   Civ_cmd4 = &H87
   Gosub Civ_print_l_5_1a0502
Return
'
402:
   Civ_cmd4 = &H87
   Gosub Civ_print4_1a0502
Return
'
403:
   B_temp1 = 10
   Civ_cmd4 = &H88
   Gosub Civ_print_l_5_1a0502
Return
'
404:
   Civ_cmd4 = &H88
   Gosub Civ_print4_1a0502
Return
'
405:
   B_temp1 = 10
   Civ_cmd4 = &H89
   Gosub Civ_print_l_5_1a0502
Return
'
406:
   Civ_cmd4 = &H89
   Gosub Civ_print4_1a0502
Return
'
407:
   B_temp1 = 9
   Civ_cmd4 = &H90
   Gosub Civ_print_l_5_1a0502
Return
'
408:
   Civ_cmd4 = &H90
   Gosub Civ_print4_1a0502
Return
'
409:
   B_temp1 = 43
   Civ_cmd4 = &H91
   Gosub Civ_print_l_5_1a0502_bcd
Return
'
40A:
   Civ_cmd4 = &H91
   Gosub Civ_print4_1a0502
Return
'
40B:
   B_temp1 = 2
   Civ_cmd4 = &H92
   Gosub Civ_print_l_5_1a0502
Return
'
40C:
   Civ_cmd4 = &H92
   Gosub Civ_print4_1a0502
Return
'
40D:
   B_temp1 = 10
   Temps_b(4) = &H93
   Gosub Send_text
Return
'
40E:
   Civ_cmd4 = &H93
   Gosub Civ_print4_1a0502
Return
'
40F:
   B_temp1 = 2
   Civ_cmd4 = &H94
   Gosub Civ_print_l_5_1a0502
Return
'
410:
   Civ_cmd4 = &H94
   Gosub Civ_print4_1a0502
Return
'
411:
   B_temp1 = 3
   Temps_b(4) = &H95
   Gosub Send_text
Return
'
412:
   Civ_cmd4 = &H95
   Gosub Civ_print4_1a0502
Return
'
413:
   B_temp1 = 44
   Temps_b(4) = &H96
   Gosub Send_text
Return
'
414:
   Civ_cmd4 = &H96
   Gosub Civ_print4_1a0502
Return
'
415:
   Temps_b(4) = &H97
   Gosub Tx_position_data
Return
'
416:
   Civ_cmd4 = &H97
   Gosub Civ_print4_1a0502
Return
'
417:
   B_temp1 = 3
   Civ_cmd4 = &H98
   Gosub Civ_print_l_5_1a0502
Return
'
418:
   Civ_cmd4 = &H98
   Gosub Civ_print4_1a0502
Return
'
419:
   W_temp1 = 361
   Civ_cmd4 = &H99
   Gosub Civ_print_2_2_bcd
Return
'
41A:
   Civ_cmd4 = &H99
   Gosub Civ_print4_1a0502
Return
'
41B:
   W_temp1 = 1851
   Civ_cmd4 = &H00
   Gosub Civ_print_2_2_bcd_3
Return
'
41C:
   Civ_cmd4 = &H00
   Gosub Civ_print4_1a0503
Return
'
41D:
   B_temp1 = 10
   Civ_cmd4 = &H01
   Gosub Civ_print_l_5_1a0503
Return
'
41E:
   Civ_cmd4 = &H01
   Gosub Civ_print4_1a0503
Return
'
41F:
   W_temp1 = 10
   Civ_cmd4 = &H02
   Gosub Civ_print_l_5_1a0503
Return
'