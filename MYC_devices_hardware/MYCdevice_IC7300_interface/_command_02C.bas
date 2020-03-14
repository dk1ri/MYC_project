' IC7300 Command 02C0 - 02DF
' 191126
'
2C0:
   Civ_cmd4 = 92
   Gosub Civ_print4_1a0501_bcd
Return
'
2C1:
   B_temp1 = 2
   Civ_cmd4 = &H93
   Gosub Civ_print_l_5_1a0501
Return
'
2C2:
   Civ_cmd4 = 93
   Gosub Civ_print4_1a0501_bcd
Return
'
2C3:
   If Commandpointer >= 3 Then
      If Command_b(3) < 4 Then
         Temps = Chr(&H1A) + Chr(&H06)
         If Command_b(3) = 0 Then
            Temps_b(3) = 0
            Temps_b(4) = 0
         Else
            Temps_b(3) = 1
            Temps_b(4) = Command_b(3)
         End If
         Civ_len = 4
         Gosub Civ_print
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
2C4:
   Temps = Chr(&H1A) + Chr(&H06)
   Civ_len = 2
   Gosub Civ_print
Return
'
2C5:
   If Commandpointer >= 3 Then
      If Command_b(3) < 2 Then
          Temps = Chr(&H1A) + Chr(&H07)
          Temps_b(3) = Command_b(3)
          Civ_len = 3
          Gosub Civ_print
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
2C6:
   Temps = Chr(&H1A) + Chr(&H07)
   Civ_len = 2
   Gosub Civ_print
Return
'
2C7:
   Civ_cmd2 = 00
   Gosub Tone
Return
'
2C8:
   Temps = Chr(&H1B) + Chr(&H00)
   Civ_len = 2
   Gosub Civ_print
Return
'
2C9:
   Civ_cmd2 = 01
   Gosub Tone
Return
'
2CA:
   Temps = Chr(&H1B) + Chr(&H01)
   Civ_len = 2
   Gosub Civ_print
Return
'
2CB:
   B_temp1 = 2
   Civ_cmd1 = &H1C
   Civ_cmd2 = &H00
   Gosub Civ_print_l_3
Return
'
2CC:
   Temps = Chr(&H1C) + Chr(&H00)
   Civ_len = 2
   Gosub Civ_print
Return
'
2CD:
   B_temp1 = 3
   Civ_cmd1 = &H1C
   Civ_cmd2 = &H01
   Gosub Civ_print_l_3
Return
'
2CE:
   Temps = Chr(&H1C) + Chr(&H01)
   Civ_len = 2
   Gosub Civ_print
Return
'
2CF:
   B_temp1 = 2
   Civ_cmd1 = &H1C
   Civ_cmd2 = &H02
   Gosub Civ_print_l_3
Return
'
2D0:
   Temps = Chr(&H1C) + Chr(&H02)
   Civ_len = 2
   Gosub Civ_print
Return
'
2D1:
   Temps = Chr(&H1C) + Chr(&H03)
   Civ_len = 2
   Gosub Civ_print
Return
'
2D2:
   B_temp1 = 2
   Civ_cmd1 = &H1C
   Civ_cmd2 = &H04
   Gosub Civ_print_l_3
Return
'
2D3:
   Temps = Chr(&H1C) + Chr(&H04)
   Civ_len = 2
   Gosub Civ_print
Return
'
2D4:
   Temps = Chr(&H1E) + Chr(&H00)
   Civ_len = 2
   Gosub Civ_print
Return
'
2D5:
   If Commandpointer >= 3 Then
      If Command_b(3) < Number_avail_tx_band Then
         Temps = Chr(&H1E) + Chr(&H01)
         B_temp1 = Command_b(3) + 1
         Temps_b(3) = Makebcd(B_temp1)
         Civ_len = 3
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
2D6:
   Temps = Chr(&H1E) + Chr(&H02)
   Civ_len = 2
   Gosub Civ_print
Return
'
2D7:
   If Commandpointer >= 11 Then
      If Command_b(3) < 30 Then
        'lower edge
        Temps = Chr(&H1E) + Chr(&H03)
        Temps_b(3) = Command_b(3)
        Frequenz_b(4) = Command_b(4)
        Frequenz_b(3) = Command_b(5)
        Frequenz_b(2) = Command_b(6)
        Frequenz_b(1) = Command_b(7)
        print Frequenz
        If Frequenz < 70000000 Then
           Temps = Chr(&H1E) + Chr(&H03)
           Temps_b(3) = Command_b(3) + 1
           Temp_dw1 = Frequenz / 1000000
           B_temp1 = Temp_dw1
           Temps_b(7) = Makebcd(B_temp1)
           Frequenz = Frequenz Mod 10000000
           Frequenz = Frequenz Mod 1000000
           Temp_dw1 = Frequenz / 10000
           B_temp1 = Temp_dw1
           Temps_b(6) = Makebcd(B_temp1)
           Frequenz = Frequenz Mod 100000
           Frequenz = Frequenz Mod 10000
           Temp_dw1 = Frequenz / 100
           B_temp1 = Temp_dw1
           Temps_b(5) = Makebcd(B_temp1)
           Frequenz = Frequenz Mod 1000
           Frequenz = Frequenz Mod 100
           B_temp1 = Frequenz
           Temps_b(4) = Makebcd(B_temp1)
  '
           Temps_b(8) = &H00
           Temps_b(9) = &H2D
  '
  'high edge
           Frequenz_b(4) = Command_b(8)
           Frequenz_b(3) = Command_b(9)
           Frequenz_b(2) = Command_b(10)
           Frequenz_b(1) = Command_b(11)
           print Frequenz
           If Frequenz < 70000000 Then
              Temp_dw1 = Frequenz / 1000000
              B_temp1 = Temp_dw1
              Temps_b(13) = Makebcd(B_temp1)
              Frequenz = Frequenz Mod 10000000
              Frequenz = Frequenz Mod 1000000
              Temp_dw1 = Frequenz / 10000
              B_temp1 = Temp_dw1
              Temps_b(12) = Makebcd(B_temp1)
              Frequenz = Frequenz Mod 100000
              Frequenz = Frequenz Mod 10000
              Temp_dw1 = Frequenz / 100
              B_temp1 = Temp_dw1
              Temps_b(11) = Makebcd(B_temp1)
              Frequenz = Frequenz Mod 1000
              Frequenz = Frequenz Mod 100
              B_temp1 = Frequenz
              Temps_b(10) = Makebcd(B_temp1)
              Temps_b(4) = &H00
              Civ_len = 14
              Gosub Civ_print
            Else
               Parameter_error
            End If
         Else
            Parameter_error
         End If
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'
2D8:
   If Commandpointer >= 3 Then
      If Command_b(3) < 30 Then
         Temps = Chr(&H1E) + Chr(&H03)
         B_temp1 = Command_b(3) + 1
         Temps_b(3) = Makebcd(B_temp1)
         Civ_len = 3
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
2D9:
   If Commandpointer >= 4 Then
   '2 byte frequency,
      W_temp1_h = Command_b(3)
      W_temp1_l = Command_b(4)
      If W_temp1 < 19999 Then
         Temps= Chr(&H21) + Chr(&H00)
         If W_temp1 > 9999 Then
            Temps_b(5) = 0
            W_temp1 = W_temp1 - 9999
         Else
            Temps_b(5) = 1
            W_temp1 = 9999 - W_temp1
         End If
         '
         W_temp2 = W_temp1 / 100
         B_temp1 = W_temp2
         Temps_b(4) =  Makebcd(B_temp1)
         W_temp1 = W_temp1 Mod 1000
         W_temp1 = W_temp1 Mod 100
         B_temp1 = W_temp1
         Temps_b(3) =  Makebcd(B_temp1)
         Civ_len = 5
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
2DA:
   Temps = Chr(&H21) + Chr(&H00)
   Civ_len = 2
   Gosub Civ_print
Return
'
2DB:
   B_temp1 = 2
   Civ_cmd1 = &H21
   Civ_cmd2 = &H01
   Gosub Civ_print_l_3
Return
'
2DC:
   Temps = Chr(&H21) + Chr(&H01)
   Civ_len = 2
   Gosub Civ_print
Return
'
2DD:
   B_temp1 = 2
   Civ_cmd1 = &H21
   Civ_cmd2 = &H02
   Gosub Civ_print_l_3
Return
'
2DE:
   Temps = Chr(&H21) + Chr(&H02)
   Civ_len = 2
   Gosub Civ_print
Return
'
2DF:
   If Commandpointer >= 7 Then
      If Command_b(3) < 2 Then
         Temps = Chr(&H25)
         Temps_b(2) = Command_b(3)
         D_temp2 = 69970000
         B_temp5 = 4
         B_temp4 = 3
         Gosub S_frequency
          Civ_len = 7
         Gosub Civ_print
      Else
         Parameter_error
      End If
      Gosub Command_received
   End If
Return
'