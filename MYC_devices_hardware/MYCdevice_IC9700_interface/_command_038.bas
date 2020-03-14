' Command 380 - 39F
' 20200305
'
380:
   Civ_cmd4 = &H22
   Gosub Civ_print4_1a0502
Return
'
381:
   B_temp1 = 60
   Civ_cmd4 = &H23
   Gosub Civ_print_l_5_plus1_1a0502_bcd
Return
'
382:
   Civ_cmd4 = &H23
   Gosub Civ_print4_1a0502
Return
'
383:
   If Commandpointer >= 3 Then
      If Command_b(3) < 18 Then
         Temps = Chr(&H1A) + Chr(&H05) + Chr(02) + CHr(&H24)
         Temps_b(5) = Makebcd(Command_b(3) + 28)
         Civ_len = 5
         Gosub Civ_print
      Else
         Parameter_error
      End If
   End If
Return
'
384:
   Civ_cmd4 = &H24
   Gosub Civ_print4_1a0502
Return
'
385:
   B_temp1 = 4
   Civ_cmd4 = &H25
   Gosub Civ_print_l_5_1a0502
Return
'
386:
   Civ_cmd4 = &H25
   Gosub Civ_print4_1a0502
Return
'
387:
   B_temp1 = 2
   Civ_cmd4 = &H26
   Gosub Civ_print_l_5_1a0502
Return
'
388:
   Civ_cmd4 = &H26
   Gosub Civ_print4_1a0502
Return
'
389:
   B_temp1 = 3
   Civ_cmd4 = &H27
   Gosub Civ_print_l_5_1a0502
Return
'
38A:
   Civ_cmd4 = &H27
   Gosub Civ_print4_1a0502
Return
'
38B:
   B_temp1 = 2
   Civ_cmd4 = &H28
   Gosub Civ_print_l_5_1a0502
Return
'
38C:
   Civ_cmd4 = &H28
   Gosub Civ_print4_1a0502
Return
'
38D:
   B_temp1 = 4
   Civ_cmd4 = &H29
   Gosub Civ_print_l_5_1a0502
Return
'
38E:
   Civ_cmd4 = &H29
   Gosub Civ_print4_1a0502
Return
'
38F:
   Civ_cmd4 = &H30
   Gosub Spectrum2
Return
'
390:
   Civ_cmd4 = &H30
   Gosub Civ_print4_1a0502
Return
'
391:
   B_temp1 = 2
   Civ_cmd4 = &H31
   Gosub Civ_print_l_5_1a0502
Return
'
392:
   Civ_cmd4 = &H31
   Gosub Civ_print4_1a0502
Return
'
393:
   B_temp1 = 2
   Civ_cmd4 = &H32
   Gosub Civ_print_l_5_1a0502
Return
'
394:
   Civ_cmd4 = &H32
   Gosub Civ_print4_1a0502
Return
'
395:
   B_temp1 = 2
   Civ_cmd4 = &H33
   Gosub Civ_print_l_5_1a0502
Return
'
396:
   Civ_cmd4 = &H33
   Gosub Civ_print4_1a0502
Return
'
397:
   B_temp1 = 2
   Civ_cmd4 = &H34
   Gosub Civ_print_l_5_1a0502
Return
'
398:
   Civ_cmd4 = &H34
   Gosub Civ_print4_1a0502
Return
'
399:
   Civ_cmd4 = &H35
   Gosub Spectrum2
Return
'
39A:
   Civ_cmd4 = &H35
   Gosub Civ_print4_1a0502
Return
'
39B:
   Civ_cmd4 = &H36
   Gosub Spectrum2
Return
'
39C:
   Civ_cmd4 = &H36
   Gosub Civ_print4_1a0502
Return
'
39D:
   B_temp1 = 2
   Civ_cmd4 = &H37
   Gosub Civ_print_l_5_1a0502
Return
'
39E:
   Civ_cmd4 = &H37
   Gosub Civ_print4_1a0502
Return
'
39F:
   B_temp1 = 2
   Civ_cmd4 = &H38
   Gosub Civ_print_l_5_1a0502
Return
'