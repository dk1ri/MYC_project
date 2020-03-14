' Command 02E0. 2FF
' 20200305
'
2E0:
   B_temp1 = 4
   Civ_cmd4 = &H36
   Gosub Civ_print_l_5_1a0501
Return
'
2E1:
   Civ_cmd4 = &H36
   Gosub Civ_print4_1a0501
Return
'
2E2:
   B_temp1 = 2
   Civ_cmd4 = &H37
   Gosub Civ_print_l_5_1a0501
Return
'
2E3:
   Civ_cmd4 = &H37
   Gosub Civ_print4_1a0501
Return
'
2E4:
   If Commandpointer >= 6 Then
      If Command_b(6) < 255 Then
         Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01) + Chr(&H38)
         Temps_b(5) = Command_b(3)
         Temps_b(6) = Command_b(4)
         Temps_b(7) = Command_b(5)
         Temps_b(8) = Command_b(6)
         Civ_len = 8
         Gosub Civ_print
      Else
         Parameter_error
      End If
   End If
Return
'
2E5:
   Civ_cmd4 = &H38
   Gosub Civ_print4_1a0501
Return
'
2E6:
   Civ_cmd4 = &H39
   Gosub Civ_print4_1a0501
Return
'
2E7:
   B_temp1 = 30
   Civ_cmd4 = &H40
   Gosub Civ_print_l_5_plus1_1a0501_bcd
Return
'
2E8:
   Civ_cmd4 = &H40
   Gosub Civ_print4_1a0501
Return
'
2E9:
   If Commandpointer >= 6 Then
      Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01) + Chr(&H41)
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
2EA:
   Civ_cmd4 = &H41
   Gosub Civ_print4_1a0501
Return
'
2EB:
   If Commandpointer >= 6 Then
      Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01) + Chr(&H42)
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
2EC:
   Civ_cmd4 = &H42
   Gosub Civ_print4_1a0501
Return
'
2ED:
   If Commandpointer >= 6 Then
      Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01) + Chr(&H43)
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
2EE:
   Civ_cmd4 = &H43
   Gosub Civ_print4_1a0501
Return
'
2EF:
   If Commandpointer >= 3 Then
      B_temp1 = Tx_b(3) + 3
      If Tx_b(3) > 0 And Tx_b(3) < 16 And Commandpointer >= B_temp1 Then
         Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01) + Chr(&H44)
         For B_temp1 = 1 To Command_b(3)
            B_temp2 = 5
            B_temp3 = 4
            Temps_b(B_temp2) = Command_b(B_temp3)
            Incr B_temp2
            Incr B_temp3
         Next B_temp1
         Civ_len = Command_b(3) + 4
         Gosub Civ_print
      Else
         Parameter_error
      End If
   End If
Return
'
2F0:
   Civ_cmd4 = &H44
   Gosub Civ_print4_1a0501
Return
'
2F1:
   B_temp1 = 2
   Civ_cmd4 = &H45
   Gosub Civ_print_l_5_1a0501
Return
'
2F2:
   Civ_cmd4 = &H45
   Gosub Civ_print4_1a0501
Return
'
2F3:
   B_temp1 = 2
   Civ_cmd4 = &H46
   Gosub Civ_print_l_5_1a0501
Return
'
2F4:
   Civ_cmd4 = &H46
   Gosub Civ_print4_1a0501
Return
'
2F5:
   If Commandpointer >= 4 Then
      W_temp1 = Command_b(3) * 256
      W_temp1 = W_temp1 + Command_b(4)
      If W_temp1 < 65535 Then
         Temps = Chr(&H1A) + Chr(&H05) + Chr(01) + Chr(&H47)
         Incr W_temp1
         Temps_b(5) = W_temp1 / 10000
         W_temp1 = W_temp1 Mod 10000
         Temps_b(6) = W_temp1 / 100
         B_temp1 = W_temp1 Mod 100
         Temps_b(7) = B_temp1
         Civ_len = 7
         Gosub Civ_print
      Else
         Parameter_error
      End If
   End If
Return
'
2F6:
   Civ_cmd4 = &H47
   Gosub Civ_print4_1a0501
Return
'
2F7:
   If Commandpointer >= 4 Then
      W_temp1 = Command_b(3) * 256
      W_temp1 = W_temp1 + Command_b(4)
      If W_temp1 < 65535 Then
         Temps = Chr(&H1A) + Chr(&H05) + Chr(01) + Chr(&H48)
         Incr W_temp1
         Temps_b(5) = W_temp1 / 10000
         W_temp1 = W_temp1 Mod 10000
         Temps_b(6) = W_temp1 / 100
         B_temp1 = W_temp1 Mod 100
         Temps_b(7) = B_temp1
         Civ_len = 7
         Gosub Civ_print
      Else
         Parameter_error
      End If
   End If
Return
'
2F8:
   Civ_cmd4 = &H48
   Gosub Civ_print4_1a0501
Return
'
2F9:
   If Commandpointer >= 4 Then
      W_temp1 = Command_b(3) * 256
      W_temp1 = W_temp1 + Command_b(4)
      If W_temp1 < 65535 Then
         Temps = Chr(&H1A) + Chr(&H05) + Chr(01) + Chr(&H49)
         Incr W_temp1
         Temps_b(5) = W_temp1 / 10000
         W_temp1 = W_temp1 Mod 10000
         Temps_b(6) = W_temp1 / 100
         B_temp1 = W_temp1 Mod 100
         Temps_b(7) = B_temp1
         Civ_len = 7
         Gosub Civ_print
      Else
         Parameter_error
      End If
   End If
Return
'
2FA:
   Civ_cmd4 = &H49
   Gosub Civ_print4_1a0501
Return
'
2FB:
   B_temp1 = 2
   Civ_cmd4 = &H50
   Gosub Civ_print_l_5_1a0501
Return
'
2FC:
   Civ_cmd4 = &H50
   Gosub Civ_print4_1a0501
Return
'
2FD:
   If Commandpointer >= 3 Then
      B_temp1 = Tx_b(3) + 3
      If Tx_b(3) > 0 And Tx_b(3) < 17 And Commandpointer >= B_temp1 Then
         Temps = Chr(&H1A) + Chr(&H05) + Chr(&H01) + Chr(&H51)
         For B_temp1 = 1 To Command_b(3)
            B_temp2 = 5
            B_temp3 = 4
            Temps_b(B_temp2) = Command_b(B_temp3)
            Incr B_temp2
            Incr B_temp3
         Next B_temp1
         Civ_len = Command_b(3) + 4
         Gosub Civ_print
      Else
         Parameter_error
      End If
   End If
Return
'
2FE:
   Civ_cmd4 = &H51
   Gosub Civ_print4_1a0501
Return
'
2FF:
   B_temp1 = 2
   Civ_cmd4 = &H52
   Gosub Civ_print_255_l_5_1a0501
Return
'