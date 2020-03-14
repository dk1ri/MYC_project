' Command 1C 1D
' 20200228
'
1C0:
   If Commandpointer >= 4 Then
      ' name
      If Command_b(4) > 0 Then
         If Command_b(4) < 11 Then
            B_temp1 = Command_b(4) + 4
            If Commandpointer >= B_temp1  Then
               W_temp1 = Command_b(3) * 114
               W_temp1 = W_temp1 + 99
               B_temp1 = B_temp1 - 4
               For B_temp2 = 1 To 16
                  If B_temp2 <= B_temp1 Then
                     Memorycontent_b(W_temp1) = Command_b(B_temp2 + 4)
                  Else
                     Memorycontent_b(W_temp1) = &H20
                  End If
                  Incr W_temp1
               Next B_temp2
               Gosub Mem_to_civ
            End If
         Else
            Parameter_error
            Gosub Command_received
         End If
      End If
   End If
Return
'
1C1:
   Mem_function = 34
   Gosub S_Read_mem
Return
'
1C2:
   If Commandpointer >= 4 Then
      'select
      If Command_b(3) < 4 Then
         W_temp1 = Command_b(3) * 114
         W_temp1 = W_temp1 + 4
         Memorycontent_b(W_temp1) = Command_b(4)
         B_temp1 = 1
         Gosub Mem_to_civ
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
1C3:
   Mem_function = 1
   Gosub S_Read_mem
Return
'
1C4:
   If Commandpointer >= 4 Then
      If Command_b(3) < 7 Then
         B_temp1 = Command_b(4)
         If B_temp1 > 0 Then
            If B_temp1 < 71 Then
               B_temp2 = B_temp1 + 4
               If Commandpointer >= B_temp2 Then
                  Incr Command_b(3)
                  Temps = Chr(&H1A) + Chr(&H02)
                  Temps_b(3) = Command_b(3)
                  For B_temp2 = 1 To B_temp1
                     Temps_b(B_temp2 + 3) = Command_b(B_temp2 + 4)
                  Next B_temp2
                  Civ_len = B_temp1 + 3
                  Gosub Civ_print
               End If
            Else
               Parameter_error
               Gosub Command_received
            End If
         End If
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
1C5:
   If Commandpointer >= 3 Then
      If Command_b(3) < 8 Then
         Temps = Chr(&H1A) + Chr(&H02)
         Temps_b(3) = Command_b(3) + 1
         Civ_len = 3
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
1C6:
   If Operating_mode = 3 Then
      Civ_cmd2 = &H03
      B_temp1 = 10
      Gosub Civ_print_l_3_1a
   Else
      Parameter_error
   End If
Return
'
1C7:
   If Operating_mode = 3 Then
      Temps = Chr(&H1A) + Chr(&H03)
      Civ_len = 2
      Last_command = &H01C7
      Gosub Civ_print
   Else
      Parameter_error
   End If
Return
'
1C8:
   If Operating_mode = 1 Or Operating_mode = 2 Then
      Civ_cmd2 = &H03
      B_temp1 = 40
      Gosub Civ_print_l_3_1a
      Else
      Parameter_error
   End If
Return
'
1C9:
   If Operating_mode = 1 Or Operating_mode = 2 Then
      Temps = Chr(&H1A) + Chr(&H03)
      Civ_len = 2
      Gosub Civ_print
      Last_command = &H01C9
   Else
      Parameter_error
   End If
Return
'
1CA:
   If Operating_mode = 4 Then
      Civ_cmd2 = &H03
      B_temp1 = 22
      Gosub Civ_print_l_3_1a
   Else
      Parameter_error
   End If
Return
'
1CB:
   If Operating_mode = 4 Then
      Temps = Chr(&H1A) + Chr(&H03)
      Civ_len = 2
      Last_command = &H01CB
      Gosub Civ_print
   Else
      Parameter_error
   End If
Return
'
1CC:
   If Operating_mode = 2 Then
      Civ_cmd2 = &H03
      B_temp1 = 50
      Gosub Civ_print_l_3_1a
      Else
      Parameter_error
   End If
Return
'
1CD:
   If Operating_mode = 2 Then
      Temps = Chr(&H1A) + Chr(&H03)
      Civ_len = 2
      Gosub Civ_print
      Last_command = &H01CD
   Else
      Parameter_error
   End If
Return
'
1CE:
   If Operating_mode = 2 Then
      Civ_cmd2 = &H04
      B_temp1 = 14
      Gosub Civ_print_l_3_1a
   Else
      Parameter_error
   End If
Return
'
1CF:
   If Operating_mode = 2 Then
      Temps = Chr(&H1A) + Chr(&H04)
      Civ_len = 2
      Gosub Civ_print
      Last_command = &H01CF
   Else
      Parameter_error
   End If
Return
'
1D0:
   If Operating_mode <> 2 Then
      Civ_cmd2 = &H04
      B_temp1 = 14
      Gosub Civ_print_l_3_1a
   Else
      Parameter_error
   End If
Return
'
1D1:
   If Operating_mode <> 2 Then
      Temps = Chr(&H1A) + Chr(&H04)
      Civ_len = 2
      Gosub Civ_print
      Last_command = &H01D1
   Else
      Parameter_error
   End If
Return
'
1D2:
   If Commandpointer >= 4 Then
      If Command_b(3) < 20 And Command_b(4) < 20 Then
         Temps = Chr(&H1A) + Chr(&H05)
         Temps_b(3) = &H00
         Temps_b(4) = &H01
         'LPF
         B_temp1 = Command_b(3)
         Temps_b(5) = Makebcd(B_temp1)
         'HPF
         B_temp1 = Command_b(4)
         B_temp1 = B_temp1 + 5
         Temps_b(6) = Makebcd(B_temp1)
         Civ_len = 6
         Gosub Civ_print
      Else
         Parameter_error
      End If
   End If
Return
'
1D3:
   Civ_cmd4 = &H01
   Gosub Civ_print4_1a0500
Return
'
1D4:
   B_temp1 = 11
   Civ_cmd4 = &H02
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1D5:
   Civ_cmd4 = &H02
   Gosub Civ_print4_1a0500
Return
'
1D6:
   B_temp1 = 11
   Civ_cmd4 = &H03
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1D7:
   Civ_cmd4 = &H03
   Gosub Civ_print4_1a0500
Return
'
1D8:
   Civ_cmd4 = &H04
   Gosub Hpf_lpf
Return
'
1D9:
   Civ_cmd4 = &H04
   Gosub Civ_print4_1a0500
Return
'
1DA:
   B_temp1 = 11
   Civ_cmd4 = &H05
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1DB:
   Civ_cmd4 = &H05
   Gosub Civ_print4_1a0500
Return
'
1DC:
   B_temp1 = 11
   Civ_cmd4 = &H06
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
1DD:
   Civ_cmd4 = &H06
   Gosub Civ_print4_1a0500
Return
'
1DE:
   Civ_cmd4 = &H07
   Gosub Hpf_lpf
Return
'
1DF:
   Civ_cmd4 = &H07
   Gosub Civ_print4_1a0500
Return
'