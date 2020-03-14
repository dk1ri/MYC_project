' Command 340 - 35F
' 20200305
'
340:
   Civ_cmd4 = &H84
   Gosub Civ_print4_1a0501
Return
'
341:
   B_temp1 = 3
   Civ_cmd4 = &H85
   Gosub Civ_print_l_5_1a0501
Return
'
342:
   Civ_cmd4 = &H85
   Gosub Civ_print4_1a0501
Return
'
343:
   B_temp1 = 3
   Civ_cmd4 = &H86
   Gosub Civ_print_l_5_1a0501
Return
'
344:
   Civ_cmd4 = &H86
   Gosub Civ_print4_1a0501
Return
'
345:
   B_temp1 = 2
   Civ_cmd4 = &H87
   Gosub Civ_print_l_5_1a0501
Return
'
346:
   Civ_cmd4 = &H87
   Gosub Civ_print4_1a0501
Return
'
347:
   B_temp1 = 3
   Civ_cmd4 = &H88
   Gosub Civ_print_l_5_1a0501
Return
'
348:
   Civ_cmd4 = &H88
   Gosub Civ_print4_1a0501
Return
'
349:
   B_temp1 = 3
   Civ_cmd4 = &H89
   Gosub Civ_print_l_5_1a0501
Return
'
34A:
   Civ_cmd4 = &H89
   Gosub Civ_print4_1a0501
Return
'
34B:
   B_temp1 = 2
   Civ_cmd4 = &H90
   Gosub Civ_print_l_5_1a0501
Return
'
34C:
   Civ_cmd4 = &H90
   Gosub Civ_print4_1a0501
Return
'
34D:
   If Commandpointer >=4 Then
      If Command_b(3) < 2 And Command_b(4) < 2 Then
         Temps = Chr(&H1A) + Chr(&H05) + CHr(&H01) + Chr(&H91)
         Temps_b(5) = Command_b(3)
         Temps_b(6) = Command_b(4)
         Civ_len = 6
         Gosub Civ_print
      Else
         Parameter_error
      End If
   End If
Return
'
34E:
   Civ_cmd4 = &H91
   Gosub Civ_print4_1a0501
Return
'
34F:
   B_temp1 = 4
   Civ_cmd4 = &H92
   Gosub Civ_print_l_5_1a0501
Return
'
350:
   Civ_cmd4 = &H92
   Gosub Civ_print4_1a0501
Return
'
351:
   B_temp1 = 2
   Civ_cmd4 = &H93
   Gosub Civ_print_l_5_1a0501
Return
'
352:
   Civ_cmd4 = &H93
   Gosub Civ_print4_1a0501
Return
'
353:
   Civ_cmd4 = &H94
   Gosub Spectrum
Return
'
354:
   Civ_cmd4 = &H94
   Gosub Civ_print4_1a0501
Return
'
355:
   Civ_cmd4 = &H95
   Gosub Spectrum
Return
'
356:
   Civ_cmd4 = &H95
   Gosub Civ_print4_1a0501
Return
'
357:
   Civ_cmd4 = &H96
   Gosub Spectrum
Return
'
358:
   Civ_cmd4 = &H96
   Gosub Civ_print4_1a0501
Return
'
359:
   B_temp1 = 2
   Civ_cmd4 = &H97
   Gosub Civ_print_l_5_1a0501
Return
'
35A:
   Civ_cmd4 = &H97
   Gosub Civ_print4_1a0501
Return
'
35B:
   B_temp1 = 3
   Civ_cmd4 = &H98
   Gosub Civ_print_l_5_1a0501
Return
'
35C:
   Civ_cmd4 = &H98
   Gosub Civ_print4_1a0501
Return
'
35D:
   B_temp1 = 3
   Civ_cmd4 = &H99
   Gosub Civ_print_l_5_1a0501
Return
'
35E:
   Civ_cmd4 = &H99
   Gosub Civ_print4_1a0501
Return
'
35F:
   B_temp1 = 3
   Civ_cmd4 = &H00
   Gosub Civ_print_l_5_1a0502
Return
'