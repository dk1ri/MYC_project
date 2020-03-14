' Command 1E0 - 1FF
' 20200220
'
1E0:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H55)
   Civ_len = 4
   Gosub Civ_print
Return
'
1E1:
   If Commandpointer >= 4 Then
      W_temp1_h = Command_b(3)
      W_temp1_l = Command_b(4)
      If W_temp1 < 10000 Then
         Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H56)
         B_temp1 = Temp_dw1 / 1000
         Temps_b(7) = B_temp1
         W_temp1 = W_temp1 Mod 1000
         B_temp1 = Temp_dw1 / 10
         Temps_b(6) = Makebcd(B_temp1)
         B_temp1 = W_temp1 Mod 10
         B_temp1 = B_temp1 * 16
         Temps_b(5) = Makebcd(B_temp1)
         Civ_len = 7
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
1E2:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H56)
   Civ_len = 4
   Gosub Civ_print
Return

1E3:
   If Commandpointer >= 4 Then
      W_temp1_h = Command_b(3)
      W_temp1_l = Command_b(4)
      If W_temp1 < 10000 Then
         Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H57)
         B_temp1 = Temp_dw1 / 1000
         Temps_b(7) = B_temp1
         W_temp1 = W_temp1 Mod 1000
         B_temp1 = Temp_dw1 / 10
         Temps_b(6) = Makebcd(B_temp1)
         B_temp1 = W_temp1 Mod 10
         B_temp1 = B_temp1 * 16
         Temps_b(5) = Makebcd(B_temp1)
         Civ_len = 7
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
1E4:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H57)
   Civ_len = 4
   Gosub Civ_print
Return
'
1E5:
   If Commandpointer >= 4 Then
      W_temp1_h = Command_b(3)
      W_temp1_l = Command_b(4)
      If W_temp1 < 10000 Then
         Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H58)
         B_temp1 = Temp_dw1 / 1000
         Temps_b(7) = B_temp1
         W_temp1 = W_temp1 Mod 1000
         B_temp1 = Temp_dw1 / 10
         Temps_b(6) = Makebcd(B_temp1)
         B_temp1 = W_temp1 Mod 10
         B_temp1 = B_temp1 * 16
         Temps_b(5) = Makebcd(B_temp1)
         Civ_len = 7
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
1E6:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H58)
   Civ_len = 4
   Gosub Civ_print
Return
'
1E7:
   B_temp1 = 2
   Civ_cmd4 = &H59
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1E8:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H59)
   Civ_len = 4
   Gosub Civ_print
Return
'
1E9:
   B_temp1 = 3
   Civ_cmd4 = &H60
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1EA:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H60)
   Civ_len = 4
   Gosub Civ_print
Return
'
1EB:
   B_temp1 = 2
   Civ_cmd4 = &H61
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1EC:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H61)
   Civ_len = 4
   Gosub Civ_print
Return
'
1ED:
   B_temp1 = 2
   Civ_cmd4 = &H62
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1EE:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H62)
   Civ_len = 4
   Gosub Civ_print
Return
'
1EF:
   B_temp1 = 2
   Civ_cmd4 = &H63
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1F0:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H63)
   Civ_len = 4
   Gosub Civ_print
Return
'
1F1:
   B_temp1 = 2
   Civ_cmd4 = &H64
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1F2:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H64)
   Civ_len = 4
   Gosub Civ_print
Return
'
1F3:
   Civ_cmd4 = &H65
   Gosub Civ_print_255_6_1a0500_bcd
Return
'
1F4:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H65)
   Civ_len = 4
   Gosub Civ_print
Return
'
1F5:
   B_temp1 = 2
   Civ_cmd4 = &H66
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1F6:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H66)
   Civ_len = 4
   Gosub Civ_print
Return
'
1F7:
   B_temp1 = 2
   Civ_cmd4 = &H67
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1F8:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H67)
   Civ_len = 4
   Gosub Civ_print
Return
'
1F9:
   B_temp1 = 2
   Civ_cmd4 = &H68
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1FA:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H68)
   Civ_len = 4
   Gosub Civ_print
Return
'
1FB:
   B_temp1 = 2
   Civ_cmd4 = &H69
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1FC:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H69)
   Civ_len = 4
   Gosub Civ_print
Return
'
1FD:
   B_temp1 = 2
   Civ_cmd4 = &H70
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1FE:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H70)
   Civ_len = 4
   Gosub Civ_print
Return
'
1FF:
   B_temp1 = 2
   Civ_cmd4 = &H71
   Gosub Civ_print_l_5_1a0500_bcd
Return