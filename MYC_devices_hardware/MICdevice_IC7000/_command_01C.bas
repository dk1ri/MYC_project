' Command4 1C0 - 1DF
' 20200220
'
1C0:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H39)
   Civ_len = 4
   Gosub Civ_print
Return
'
1C1:
   If Commandpointer >= 4 Then
      If Command_b(3) < 12 And Command_b(4) < 31 Then
         Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H40)
         Temps_b(5) = Makebcd(Command_b(4) + 1)
         Temps_b(6) = Makebcd(Command_b(5) + 1)
         Civ_len = 6
         Gosub Civ_print
       Else
         Parameter_error
      End If
   End If
Return
'
1C2:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H40)
   Civ_len = 4
   Gosub Civ_print
Return
'
1C3:
   If Commandpointer >= 4 Then
      If Command_b(3) < 24 And Command_b(4) < 60 Then
         Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H41)
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
1C4:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H41)
   Civ_len = 4
   Gosub Civ_print
Return
'
1C5:
   B_temp1 = 2
   Civ_cmd4 = &H42
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1C6:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H42)
   Civ_len = 4
   Gosub Civ_print
Return
'
1C7:
   If Commandpointer >= 4 Then
      W_temp1_h = Command_b(3)
      W_temp1_l = Command_b(4)
      If W_temp1 < 2880 Then
         Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H43)
         If W_temp1 <= 1140 Then
            '-
            W_temp1 = 1140 - W_temp1
            Temps_b(7) = 1
         Else
            W_temp1 = W_temp1 - 1140
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
1C8:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H43)
   Civ_len = 4
   Gosub Civ_print
Return
'
1C9:
   B_temp1 = 3
   Civ_cmd4 = &H44
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1CA:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H44)
   Civ_len = 4
   Gosub Civ_print
Return
'
1CB:
   B_temp1 = 2
   Civ_cmd4 = &H45
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1CC:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H45)
   Civ_len = 4
   Gosub Civ_print
Return
'
1CD:
   Civ_cmd4 = &H46
   Gosub Civ_print_255_6_1a0500_bcd
Return
'
1CE:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H46)
   Civ_len = 4
   Gosub Civ_print
Return
'
1CF:
   B_temp1 = 2
   Civ_cmd4 = &H47
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1D0:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H47)
   Civ_len = 4
   Gosub Civ_print
Return
'
1D1:
   B_temp1 = 2
   Civ_cmd4 = &H48
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1D2:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H48)
   Civ_len = 4
   Gosub Civ_print
Return
'
1D3:
   Civ_cmd4 = &H49
   Gosub Civ_print_255_6_1a0500_bcd
Return
'
1D4:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H49)
   Civ_len = 4
   Gosub Civ_print
Return
'
1D5:
   B_temp1 = 2
   Civ_cmd4 = &H50
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1D6:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H50)
   Civ_len = 4
   Gosub Civ_print
Return
'
1D7:
   B_temp1 = 3
   Civ_cmd4 = &H51
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1D8:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H51)
   Civ_len = 4
   Gosub Civ_print
Return
'
1D9:
   B_temp1 = 2
   Civ_cmd4 = &H52
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1DA:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H52)
   Civ_len = 4
   Gosub Civ_print
Return
'
1DB:
   If Commandpointer >= 4 Then
      W_temp1_h = Command_b(3)
      W_temp1_l = Command_b(4)
      If W_temp1 < 20000 Then
         Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H53)
         If W_temp1 < 10000 Then
            Temps_b(8) = 1
            ' 9999 is "0"
            W_temp1 = 9999 - W_temp1
         Else
            Temps_b(8) = 0
            W_temp1 = W_temp1 - 1000
         End If
         B_temp1 = Temp_dw1 / 1000
         Temps_b(7) = B_temp1
         W_temp1 = W_temp1 Mod 1000
         B_temp1 = Temp_dw1 / 10
         Temps_b(6) = Makebcd(B_temp1)
         B_temp1 = W_temp1 Mod 10
         B_temp1 = B_temp1 * 16
         Temps_b(5) = Makebcd(B_temp1)
         Civ_len = 8
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
1DC:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H53)
   Civ_len = 4
   Gosub Civ_print
Return
'
1DD:
   B_temp1 = 2
   Civ_cmd4 = &H54
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1DE:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H54)
   Civ_len = 4
   Gosub Civ_print
Return
'
1DF:
   If Commandpointer >= 4 Then
      W_temp1_h = Command_b(3)
      W_temp1_l = Command_b(4)
      If W_temp1 < 10000 Then
         Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H55)
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