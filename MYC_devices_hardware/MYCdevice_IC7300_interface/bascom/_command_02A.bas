' IC7300 Command 2A0 - 2BF
' 191129
'
2A0:
   Civ_cmd4 = &H76
   Gosub Civ_print4_1a0501
Return
2A1:
   B_temp1 = 2
   Civ_cmd4 = &H77
   Gosub Civ_print_l_5_1a0501
Return
2A2:
   Civ_cmd4 = &H77
   Gosub Civ_print4_1a0501
Return
2A3:
   B_temp1 = 2
   Civ_cmd4 = &H78
   Gosub Civ_print_l_5_1a0501
Return
2A4:
   Civ_cmd4 = &H78
   Gosub Civ_print4_1a0501
Return
2A5:
   B_temp1 = 2
   Civ_cmd4 = &H79
   Gosub Civ_print_l_5_1a0501
Return
2A6:
   Civ_cmd4 = &H79
   Gosub Civ_print4_1a0501
Return
2A7:
   B_temp1 = 2
   Civ_cmd4 = &H80
   Gosub Civ_print_l_5_1a0501
Return
2A8:
   Civ_cmd4 = &H80
   Gosub Civ_print4_1a0501
Return
2A9:
   If Commandpointer >= 3 Then
      If Command_b(3) < 15 Then
         Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01) + Chr(&H81)
         B_temp1 =  Command_b(3) + 1
         Temps_b(5) = Makebcd(B_temp1)
         Civ_len = 5
         Gosub Civ_print
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
2AA:
   Civ_cmd4 = &H81
   Gosub Civ_print4_1a0501
Return
2AB:
   B_temp1 = 2
   Civ_cmd4 = &H82
   Gosub Civ_print_l_5_1a0501
Return
2AC:
   Civ_cmd4 = &H82
   Gosub Civ_print4_1a0501
Return
2AD:
   B_temp1 = 2
   Civ_cmd4 = &H83
   Gosub Civ_print_l_5_1a0501
Return
2AE:
   Civ_cmd4 = &H83
   Gosub Civ_print4_1a0501
Return
2AF:
   B_temp1 = 2
   Civ_cmd4 = &H84
   Gosub Civ_print_l_5_1a0501
Return
2B0:
   Civ_cmd4 = &H84
   Gosub Civ_print4_1a0501
Return
2B1:
   B_temp1 = 2
   Civ_cmd4 = &H85
   Gosub Civ_print_l_5_1a0501
Return
2B2:
   Civ_cmd4 = &H85
   Gosub Civ_print4_1a0501
Return
2B3:
   B_temp1 = 2
   Civ_cmd4 = &H86
   Gosub Civ_print_l_5_1a0501
Return
2B4:
   Civ_cmd4 = &H86
   Gosub Civ_print4_1a0501
Return
2B5:
   B_temp1 = 4
   Civ_cmd4 = &H87
   Gosub Civ_print_l_5_1a0501
Return
2B6:
   Civ_cmd4 = &H87
   Gosub Civ_print4_1a0501
Return
2B7:
   B_temp1 = 4
   Civ_cmd4 = &H88
   Gosub Civ_print_l_5_1a0501
Return
2B8:
   Civ_cmd4 = &H88
   Gosub Civ_print4_1a0501
Return
2B9:
   B_temp1 = 10
   Civ_cmd4 = &H89
   Gosub Civ_print_l_5_1a0501
Return
2BA:
   Civ_cmd4 = 89
   Gosub Civ_print4_1a0501_bcd
Return
2BB:
   Civ_cmd4 = &H90
   Gosub Civ_print_255_6_1a0501_bcd
Return
2BC:
   Civ_cmd4 = 90
   Gosub Civ_print4_1a0501_bcd
Return
2BD:
   If Commandpointer >= 3 Then
      If Command_b(3) < 21 Then
          Temps = Chr(&H1A) + Chr(&H05)
          Temps_b(3) = &H01
          Temps_b(4) = &H91
          Temps_b(5) = Makebcd(Command_b(3))
          Civ_len = 5
          Gosub Civ_print
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
2BE:
   Civ_cmd4 = 91
   Gosub Civ_print4_1a0501_bcd
Return
2BF:
   B_temp1 = 4
   Civ_cmd4 = &H92
   Gosub Civ_print_l_5_1a0501
Return