' Command 420 - 43F
' 20200310
'
420:
   Civ_cmd4 = &H02
   Gosub Civ_print4_1a0503
Return
'
421:
   W_temp1 = 10
   Civ_cmd4 = &H03
   Gosub Civ_print_l_5_1a0503
Return
'
422:
   Civ_cmd4 = &H03
   Gosub Civ_print4_1a0503
Return
'
423:
   B_temp1 = 9
   Civ_cmd4 = &H04
   Gosub Civ_print_l_5_1a0503
Return
'
424:
   Civ_cmd4 = &H04
   Gosub Civ_print4_1a0503
Return
'
425:
   B_temp1 = 44
   Civ_cmd4 = &H05
   Gosub Civ_print_l_5_1a0503_bcd
Return
'
426:
   Civ_cmd4 = &H05
   Gosub Civ_print4_1a0503
Return
'
427:
   B_temp1 = 9
   Civ_cmd4 = &H06
   Gosub Send_text_3
Return
'
428:
   Civ_cmd4 = &H06
   Gosub Civ_print4_1a0503
Return
'
429:
   B_temp1 = 43
   Civ_cmd4 = &H07
   Gosub Civ_print_l_5_1a0503_bcd
Return
'
42A:
   Civ_cmd4 = &H07
   Gosub Civ_print4_1a0503
Return
'
42B:
   B_temp1 = 44
   Civ_cmd4 = &H08
   Gosub Send_text_3
Return
'
42C:
   Civ_cmd4 = &H08
   Gosub Civ_print4_1a0503
Return
'
42D:
   B_temp1 = 3
   Temps_b(4) = &H09
   Gosub Civ_print_l_5_1a0503
Return
'
42E:
   Civ_cmd4 = &H09
   Gosub Civ_print4_1a0503
Return
'
42F:
   B_temp1 = 2
   Civ_cmd4 = &H10
   Gosub Civ_print_l_5_1a0503
Return
'
430:
   Civ_cmd4 = &H10
   Gosub Civ_print4_1a0503
Return
'
431:
   B_temp1 = 2
   Temps_b(4) = &H11
   Gosub Civ_print_l_5_1a0503
Return
'
432:
   Civ_cmd4 = &H11
   Gosub Civ_print4_1a0503
Return
'
433:
   B_temp1 = 2
   Temps_b(4) = &H12
   Gosub Civ_print_l_5_1a0503
Return
'
434:
   Civ_cmd4 = &H12
   Gosub Civ_print4_1a0503
Return
'
435:
   B_temp1 = 2
   Temps_b(4) = &H13
   Gosub Civ_print_l_5_1a0503
Return
'
436:
   Civ_cmd4 = &H13
   Gosub Civ_print4_1a0503
Return
'
437:
   B_temp1 = 2
   Temps_b(4) = &H14
   Gosub Civ_print_l_5_1a0503
Return
'
438:
   Civ_cmd4 = &H14
   Gosub Civ_print4_1a0503
Return
'
439:
   B_temp1 = 2
   Civ_cmd4 = &H15
   Gosub Civ_print_l_5_1a0503
Return
'
43A:
   Civ_cmd4 = &H15
   Gosub Civ_print4_1a0503
Return
'
43B:
   B_temp1 = 21
   Civ_cmd4 = &H16
   Gosub Send_text_3
Return
'
43C:
   Civ_cmd4 = &H16
   Gosub Civ_print4_1a0503
Return
'
43D:
   If Commandpointer >= 4 Then
      W_temp1 = Command_b(3) * 256
      W_temp1 = W_temp1 + Command_b(4)
      If W_temp1 < 60000 Then
         Temps = Chr(&H1A) + Chr(&H05) + Chr(&H03) + Chr(&H17)
         Temps_b(5) = W_temp1 / 1000
         W_temp1 = W_temp1 Mod 1000
         Temps_b(6) = W_temp1 / 10
         B_temp1 = W_temp1 Mod 10
         Shift B_temp1, Left, 4
         Temps_b(7) = B_temp1
         Civ_len = 7
         Gosub Civ_print
      Else
         Parameter_error
      End If
   End If
   B_temp1 = 10
   Civ_cmd4 = &H17
   Gosub Civ_print_l_5_1a0503
Return
'
43E:
   Civ_cmd4 = &H17
   Gosub Civ_print4_1a0503
Return
'
43F:
   W_temp1 = 3
   Civ_cmd4 = &H18
   Gosub Civ_print_l_5_1a0503
Return
'