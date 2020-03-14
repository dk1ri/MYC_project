' Command 320 - 33F
' 20200305
'
320:
   Civ_cmd4 = &H68
   Gosub Civ_print4_1a0501
Return
'
321:
   B_temp1 = 2
   Civ_cmd4 = &H69
   Gosub Civ_print_l_5_1a0501
Return
'
322:
   Civ_cmd4 = &H69
   Gosub Civ_print4_1a0501
Return
'
323:
   B_temp1 = 2
   Civ_cmd4 = &H70
   Gosub Civ_print_l_5_1a0501
Return
'
324:
   Civ_cmd4 = &H70
   Gosub Civ_print4_1a0501
Return
'
325:
   B_temp1 = 2
   Civ_cmd4 = &H71
   Gosub Civ_print_l_5_1a0501
Return
'
326:
   Civ_cmd4 = &H71
   Gosub Civ_print4_1a0501
Return
'
327:
   B_temp1 = 3
   Civ_cmd4 = &H72
   Gosub Civ_print_l_5_1a0501
Return
'
328:
   Civ_cmd4 = &H72
   Gosub Civ_print4_1a0501
Return
'
329:
   B_temp1 = 2
   Civ_cmd4 = &H73
   Gosub Civ_print_l_5_1a0501
Return
'
32A:
   Civ_cmd4 = &H73
   Gosub Civ_print4_1a0501
Return
'
32B:
   B_temp1 = 4
   Civ_cmd4 = &H74
   Gosub Civ_print_l_5_1a0501
Return
'
32C:
   Civ_cmd4 = &H74
   Gosub Civ_print4_1a0501
Return
'
32D:
   B_temp1 = 2
   Civ_cmd4 = &H75
   Gosub Civ_print_l_5_1a0501
Return
'
32E:
   Civ_cmd4 = &H75
   Gosub Civ_print4_1a0501
Return
'
32F:
   B_temp1 = 4
   Civ_cmd4 = &H76
   Gosub Civ_print_l_5_1a0501
Return
'
330:
   Civ_cmd4 = &H76
   Gosub Civ_print4_1a0501
Return
'
331:
   B_temp1 = 2
   Civ_cmd4 = &H77
   Gosub Civ_print_l_5_1a0501
Return
'
332:
   Civ_cmd4 = &H77
   Gosub Civ_print4_1a0501
Return
'
333:
   B_temp1 = 2
   Civ_cmd4 = &H78
   Gosub Civ_print_l_5_1a0501
Return
'
334:
   Civ_cmd4 = &H78
   Gosub Civ_print4_1a0501
Return
'
335:
   If Commandpointer >= 5 Then
      If Command_b(3) < 100 And Command_b(4) < 12 And Command_b(5) < 31 Then
         Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01) + Chr(&H79) + Chr(&H20)
         Temps_b(5) = &H20
         Temps_b(6) = Makebcd(Command_b(3))
         Temps_b(7) = Makebcd(Command_b(4))
         Temps_b(8) = Makebcd(Command_b(5))
         Civ_len = 8
         Gosub Civ_print
       Else
         Parameter_error
      End If
   End If
Return
'
336:
   Civ_cmd4 = &H79
   Gosub Civ_print4_1a0501
Return
'
337:
   If Commandpointer >= 4 Then
      If Command_b(3) < 24 And Command_b(4) < 60 Then
         Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01) + Chr(&H80)
         Temps_b(5) = Makebcd(Command_b(3))
         Temps_b(6) = Makebcd(Command_b(4))
         Civ_len = 6
         Gosub Civ_print
       Else
         Parameter_error
      End If
   End If
Return
'
338:
   Civ_cmd4 = &H80
   Gosub Civ_print4_1a0501
Return
'
339:
   B_temp1 = 2
   Civ_cmd4 = &H81
   Gosub Civ_print_l_5_1a0501
Return
'
33A:
   Civ_cmd4 = &H81
   Gosub Civ_print4_1a0501
Return
'
33B:
   If Commandpointer >= 6 Then
      Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01) + Chr(&H82)
      If Command_b(6) = 0 Then
         Temps_b(5) = &HFF
         Civ_len = 5
         Gosub Civ_print
      Else
         Temps_b(5) = Command_b(3)
         Temps_b(6) = Command_b(4)
         Temps_b(7) = Command_b(5)
         Temps_b(8) = Command_b(6)
         Civ_len = 8
         Gosub Civ_print
      End If
   End If
Return
'
33C:
   Civ_cmd4 = &H82
   Gosub Civ_print4_1a0501
Return
'
33D:
   B_temp1 = 2
   Civ_cmd4 = &H83
   Gosub Civ_print_l_5_1a0501
Return
'
33E:
   Civ_cmd4 = &H83
   Gosub Civ_print4_1a0501
Return
'
33F:
   If Commandpointer >= 4 Then
      W_temp1_h = Command_b(3)
      W_temp1_l = Command_b(4)
      If W_temp1 < 1681 Then
         Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01) + Chr(&H84)
         If W_temp1 <= 840 Then
            '-
            W_temp1 = 840 - W_temp1
            Temps_b(7) = 1
         Else
            W_temp1 = W_temp1 - 840
            Temps_b(7) = 0
         End If
         W_temp2 = W_temp1 / 60
         B_temp1 = W_temp2
         W_temp2 = W_temp1 Mod 60
         B_temp2 = W_temp2
         Temps_b(5) = Makebcd(B_temp1)
         Temps_b(6) = Makebcd(B_temp2)
         Civ_len = 6
         Gosub Civ_print
      Else
         parameter_error
      End If
   End If
Return
'