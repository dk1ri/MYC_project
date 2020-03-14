' Command 440 - 45F
' 20200310
'
440:
   Civ_cmd4 = &H18
   Gosub Civ_print4_1a0503
Return
'
441:
   W_temp1 = 9
   Civ_cmd4 = &H19
   Gosub Civ_print_l_5_1a0503
Return
'
442:
   Civ_cmd4 = &H19
   Gosub Civ_print4_1a0503
Return
'
443:
   B_temp1 = 4
   Civ_cmd4 = &H20
   Gosub Civ_print_l_5_1a0503
Return
'
444:
   Civ_cmd4 = &H20
   Gosub Civ_print4_1a0503
Return
'
445:
   Civ_cmd4 = &H21
   Gosub Civ_print_255_l_5_1a0503
Return
'
446:
   Civ_cmd4 = &H21
   Gosub Civ_print4_1a0503
Return
'
447:
   B_temp1 = 10
   Civ_cmd4 = &H22
   Gosub Send_text_3
Return
'
448:
   Civ_cmd4 = &H22
   Gosub Civ_print4_1a0503
Return
'
449:
   Civ_cmd4 = &H23
   Gosub Civ_print_255_l_5_1a0503
Return
'
44A:
   Civ_cmd4 = &H23
   Gosub Civ_print4_1a0503
Return
'
44B:
   Civ_cmd4 = &H24
   Gosub Civ_print_255_l_5_1a0503
Return
'
44C:
   Civ_cmd4 = &H24
   Gosub Civ_print4_1a0503
Return
'
44D:
   B_temp1 = 10
   Temps_b(4) = &H25
   Gosub Civ_print_l_5_1a0503
Return
'
44E:
   Civ_cmd4 = &H25
   Gosub Civ_print4_1a0503
Return
'
44F:
   Civ_cmd4 = &H26
   Gosub Civ_print_255_l_5_1a0503
Return
'
450:
   Civ_cmd4 = &H26
   Gosub Civ_print4_1a0503
Return
'
451:
   Temps_b(4) = &H27
   Gosub Civ_print_255_l_5_1a0503
Return
'
452:
   Civ_cmd4 = &H27
   Gosub Civ_print4_1a0503
Return
'
453:
   B_temp1 = 10
   Temps_b(4) = &H28
   Gosub Civ_print_l_5_1a0503
Return
'
454:
   Civ_cmd4 = &H28
   Gosub Civ_print4_1a0503
Return
'
455:
   B_temp1 = 2
   Temps_b(4) = &H29
   Gosub Civ_print_255_l_5_1a0503
Return
'
456:
   Civ_cmd4 = &H29
   Gosub Civ_print4_1a0503
Return
'
457:
   B_temp1 = 21
   Temps_b(4) = &H30
   Gosub Civ_print_l_5_1a0503_bcd
Return
'
458:
   Civ_cmd4 = &H30
   Gosub Civ_print4_1a0503
Return
'
459:
   B_temp1 = 4
   Civ_cmd4 = &H31
   Gosub Civ_print_l_5_1a0503
Return
'
45A:
   Civ_cmd4 = &H31
   Gosub Civ_print4_1a0503
Return
'
45B:
   B_temp1 = 2
   Civ_cmd4 = &H32
   Gosub Civ_print_l_5_1a0503
Return
'
45C:
   Civ_cmd4 = &H32
   Gosub Civ_print4_1a0503
Return
'
45D:
   Temps_b(4) = &H33
   Gosub Civ_print_255_l_5_1a0503
Return
'
45E:
   Civ_cmd4 = &H33
   Gosub Civ_print4_1a0503
Return
'
45F:
   W_temp1 = 2
   Civ_cmd4 = &H34
   Gosub Civ_print_l_5_1a0503
Return
'