' IC7300 Command 260 - 27F
' 191129
'
260:
   B_temp1 = 3
   Civ_cmd4 = &H30
   Gosub Civ_print_l_5_1a0501_answer1
Return
261:
   F_offset = 20000
   D_temp1 = 22000
   Civ_cmd4 = &H33
   Gosub S_scope_edge
Return
262:
   B_temp1 = 3
   Civ_cmd4 = &H33
   Gosub Civ_print_l_5_1a0501_answer1
Return
263:
   F_offset = 22000
   D_temp1 = 26000
   Civ_cmd4 = &H36
   Gosub S_scope_edge
Return
264:
   B_temp1 = 3
   Civ_cmd4 = &H36
   Gosub Civ_print_l_5_1a0501_answer1
Return
265:
   F_offset = 26000
   D_temp1 = 30000
   Civ_cmd4 = &H39
   Gosub S_scope_edge
Return
266:
   B_temp1 = 3
   Civ_cmd4 = &H39
   Gosub Civ_print_l_5_1a0501_answer1
Return
267:
   F_offset = 30000
   D_temp1 = 45000
   Civ_cmd4 = &H42
   Gosub S_scope_edge
Return
   B_temp1 = 3
268:
   Civ_cmd4 = &H42
   Gosub Civ_print_l_5_1a0501_answer1
Return
269:
   F_offset = 45000
   D_temp1 = 60000
   Civ_cmd4 = &H45
   Gosub S_scope_edge
Return
26A:
   B_temp1 = 3
   Civ_cmd4 = &H45
   Gosub Civ_print_l_5_1a0501_answer1
Return
26B:
   F_offset = 60000
   D_temp1 = 74800
   Civ_cmd4 = &H48
   Gosub S_scope_edge
Return
26C:
   B_temp1 = 3
   Civ_cmd4 = &H48
   Gosub Civ_print_l_5_1a0501_answer1
Return
26D:
   B_temp1 = 2
   Civ_cmd4 = &H51
   Gosub Civ_print_l_5_1a0501
Return
26E:
   Civ_cmd4 = &H51
   Gosub Civ_print4_1a0501
Return
26F:
   Civ_cmd4 = &H52
   Gosub Spectrum
Return
270:
   Civ_cmd4 = &H52
   Gosub Civ_print4_1a0501
Return
271:
   B_temp1 = 2
   Civ_cmd4 = &H53
   Gosub Civ_print_l_5_1a0501
Return
272:
   Civ_cmd4 = &H53
   Gosub Civ_print4_1a0501
Return
273:
   Civ_cmd4 = &H54
   Gosub Spectrum
Return
274:
   Civ_cmd4 = &H54
   Gosub Civ_print4_1a0501
Return
275:
   B_temp1 = 5
   Civ_cmd4 = &H55
   Gosub Civ_print_l_5_1a0501
Return
276:
   Civ_cmd4 = &H55
   Gosub Civ_print4_1a0501
Return
277:
   B_temp1 = 9
   Civ_cmd4 = &H56
   Incr Command_b(3)
   Gosub Civ_print_l_5_1a0501
Return
278:
   Civ_cmd4 = &H56
   Gosub Civ_print4_1a0501
Return
279:
   If Commandpointer >= 4 Then
      W_temp1 = Command_b(3) * 256
      W_temp1 = W_temp1 + Command_b(4)
      If W_temp1 < 9999 Then
         Temps = Chr(&H1A) + Chr(&H05)+ Chr(&H01) + Chr(&H57)
         Incr W_temp1
         W_temp2 = W_temp1 / 100
         B_temp1 = W_temp2
         Temps_b(5) = Makebcd(B_temp1)
         W_temp1 = W_temp1 Mod  1000
         W_temp1 = W_temp1 Mod  100
         B_temp1 = W_temp1
         Temps_b(6) = Makebcd(B_temp1)
         Civ_len = 6
         Gosub Civ_print
      Else
         Parameter_error
      End If
   End If
Return
27A:
   Civ_cmd4 = &H57
   Gosub Civ_print4_1a0501
Return
27B:
   Civ_cmd4 = &H58
   Gosub Civ_print_255_6_1a0501_bcd
Return
27C:
   Civ_cmd4 = &H58
   Gosub Civ_print4_1a0501
Return
27D:
   B_temp1 = 2
   Civ_cmd4 = &H59
   Gosub Civ_print_l_5_1a0501
Return
27E:
   Civ_cmd4 = &H59
   Gosub Civ_print4_1a0501
Return
27F:
   If Commandpointer >= 3 Then
      If Command_b(3) < 60 Then
         Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01) + Chr(&H60)
         Incr Command_b(3)
         B_temp1 = Makebcd(Command_b(3))
         Temps_b(5) = B_temp1
         Civ_len = 5
         Gosub Civ_print
      Else
         Parameter_error
      End If
   End If
Return