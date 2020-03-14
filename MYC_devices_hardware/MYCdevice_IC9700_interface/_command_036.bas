' Command 360 - 37F
' 20200305
'
360:
   Civ_cmd4 = &H00
   Gosub Civ_print4_1a0502
Return
'
361:
   B_temp1 = 2
   Civ_cmd4 = &H01
   Gosub Civ_print_l_5_1a0502
Return
'
362:
   Civ_cmd4 = &H01
   Gosub Civ_print4_1a0502
Return
'
363:
   F_offset = 6000
   D_temp1 = 8000
   Civ_cmd4 = &H02
   Gosub S_scope_edge
Return
'
364:
   Civ_cmd4 = &H02
   Gosub Civ_print4_1a0502
Return
'
365:
   F_offset = 6000
   D_temp1 = 8000
   Civ_cmd4 = &H05
   Gosub S_scope_edge
Return
'
366:
   Civ_cmd4 = &H05
   Gosub Civ_print4_1a0502
Return
'
367:
   F_offset = 6000
   D_temp1 = 8000
   Civ_cmd4 = &H08
   Gosub S_scope_edge
Return
'
368:
   Civ_cmd4 = &H08
   Gosub Civ_print4_1a0502
Return
'
369:
   B_temp1 = 2
   Civ_cmd4 = &H11
   Gosub Civ_print_l_5_1a0502
Return
'
36A:
   Civ_cmd4 = &H11
   Gosub Civ_print4_1a0502
Return
'
36B:
   Civ_cmd4 = &H12
   Gosub Spectrum2
Return
'
36C:
   Civ_cmd4 = &H12
   Gosub Civ_print4_1a0502
Return
'
36D:
   B_temp1 = 2
   Civ_cmd4 = &H13
   Gosub Civ_print_l_5_1a0502
Return
'
36E:
   Civ_cmd4 = &H13
   Gosub Civ_print4_1a0502
Return
'
36F:
   Civ_cmd4 = &H14
   Gosub Spectrum2
Return
'
370:
   Civ_cmd4 = &H14
   Gosub Civ_print4_1a0502
Return
'
371:
   Civ_cmd4 = &H15
   Gosub Civ_print_255_l_5_1a0502
Return
'
372:
   Civ_cmd4 = &H15
   Gosub Civ_print4_1a0502
Return
'
373:
   B_temp1 = 2
   Civ_cmd4 = &H16
   Gosub Civ_print_l_5_1a0502
Return
'
374:
   Civ_cmd4 = &H16
   Gosub Civ_print4_1a0502
Return
'
375:
   B_temp1 = 15
   Civ_cmd4 = &H17
   Gosub Civ_print_l_5_plus1_1a0502_bcd
Return
'
376:
   Civ_cmd4 = &H17
   Gosub Civ_print4_1a0502
Return
'
377:
   B_temp1 = 5
   Civ_cmd4 = &H18
   Gosub Civ_print_l_5_1a0502
Return
'
378:
   Civ_cmd4 = &H18
   Gosub Civ_print4_1a0502
Return
'
379:
   B_temp1 = 15
   Civ_cmd4 = &H19
   Gosub Civ_print_l_5_plus1_1a0502_bcd
Return
'
37A:
   Civ_cmd4 = &H19
   Gosub Civ_print4_1a0502
Return
'
37B:
   If Commandpointer >= 4 Then
      W_temp1 = Command_b(3) * 256
      W_temp1 = W_temp1 + Command_b(4)
      If W_temp1 < 9999 Then
         Temps = Chr(&H1A) + Chr(&H05) + Chr(02) + CHr(&H20)
         B_temp1 = W_temp1 / 100
         Temps_b(5) = Makebcd(B_temp1)
         B_temp1 = W_temp1 Mod 100
         Temps_b(6) = Makebcd(B_temp1)
         Civ_len = 6
         Gosub Civ_print
      Else
         Parameter_error
      End If
   End If
Return
'
37C:
   Civ_cmd4 = &H20
   Gosub Civ_print4_1a0502
Return
'
37D:
   Civ_cmd4 = &H21
   Gosub Civ_print_255_l_5_1a0502
Return
'
37E:
   Civ_cmd4 = &H21
   Gosub Civ_print4_1a0502
Return
'
37F:
   B_temp1 = 2
   Civ_cmd4 = &H22
   Gosub Civ_print_l_5_1a0502
Return
'