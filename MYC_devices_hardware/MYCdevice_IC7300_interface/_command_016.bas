' IC7300 Command 160 - 17F
' 191129
'
160:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H50
   B_temp1 = 2
   Gosub Civ_print_l_3
Return
161:
   Temps = Chr(&H16) + Chr(&H50)
   Civ_len = 2
   Gosub Civ_print
Return
162:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H56
   B_temp1 = 2
   Gosub Civ_print_l_3
Return
163:
   Temps = Chr(&H16) + Chr(&H56)
   Civ_len = 2
   Gosub Civ_print
Return
164:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H57
   B_temp1 = 3
   Gosub Civ_print_l_3
Return
165:
   Temps = Chr(&H16) + Chr(&H57)
   Civ_len = 2
   Gosub Civ_print
Return
166:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H58
   B_temp1 = 3
   Gosub Civ_print_l_3
Return
167:
    Temps = Chr(&H16) + Chr(&H58)
   Civ_len = 2
   Gosub Civ_print
Return
168:
   If Commandpointer >= 3 Then
      B_temp3 = Command_b(3)
      If B_temp3 > 0 And B_temp3 <= 30 Then
         B_temp4 = B_temp3 + 3
         If Commandpointer >= B_temp4 Then
            Temps_b(1) = &H17
            For B_temp1 = 1 to B_temp3
               B_temp2 = B_temp1 + 1
               Temps_b(B_temp2) = Command_b(B_temp1 + 3)
            Next B_temp1
            Civ_len = B_temp3 + 1
            Gosub Civ_print
         End If
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
169:
   If Commandpointer >= 3 Then
      If Command_b(3) < 2 Then
         If Command_b(3) = 0 Then
            Temps = Chr(&H18)
            Temps_b(2) = &H00
            Civ_len = 2
            Gosub Civ_print
         Else
            Stop Watchdog
            For B_temp1= 1 To 25
               Printbin #2, &HFE
            Next B_temp1
            Temps = Chr(&H18) + Chr(&H01)
            Civ_len = 2
            Gosub Civ_print
            Start Watchdog
         End If
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
16A:
   Temps = Chr(&H19)
   Temps_b(2) = &H00
   Civ_len = 2
   Gosub Civ_print
Return
16B:
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
16C:
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
16D:
   If Operating_mode = 2 Then
      Civ_cmd2 = &H03
      B_temp1 = 50
      Gosub Civ_print_l_3_1a
   Else
      Parameter_error
   End If
Return
16E:
   If Operating_mode = 2 Then
      Temps = Chr(&H1A) + Chr(&H03)
      Civ_len = 2
      Gosub Civ_print
   Else
      Parameter_error
   End If
Return
16F:
   If Operating_mode <> 2 Then
      Civ_cmd2 = &H03
      B_temp1 = 40
      Gosub Civ_print_l_3_1a
      Else
      Parameter_error
   End If
Return
170:
   If Operating_mode <> 2 Then
      Temps = Chr(&H1A) + Chr(&H03)
      Civ_len = 2
      Gosub Civ_print
   Else
      Parameter_error
   End If
Return
171:
   If Operating_mode = 2 Then
      Civ_cmd2 = &H04
      B_temp1 = 14
      Gosub Civ_print_l_3_1a
   Else
      Parameter_error
   End If
Return
172:
   If Operating_mode = 2 Then
      Temps = Chr(&H1A) + Chr(&H04)
      Civ_len = 2
      Gosub Civ_print
   Else
      Parameter_error
   End If
Return
173:
   If Operating_mode <> 2 Then
      Civ_cmd2 = &H04
      B_temp1 = 14
      Gosub Civ_print_l_3_1a
   Else
      Parameter_error
   End If
Return
174:
   If Operating_mode <> 2 Then
      Temps = Chr(&H1A) + Chr(&H04)
      Civ_len = 2
      Gosub Civ_print
   Else
      Parameter_error
   End If
Return
175:
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
176:
   Civ_cmd4 = &H01
   Gosub Civ_print4_1a0500
Return
177:
   B_temp1 = 11
   Civ_cmd4 = &H02
   Gosub Civ_print_l_5_1a0500_bcd
Return
178:
   Civ_cmd4 = &H02
   Gosub Civ_print4_1a0500
Return
179:
   B_temp1 = 11
   Civ_cmd4 = &H03
   Gosub Civ_print_l_5_1a0500_bcd
Return
17A:
   Civ_cmd4 = &H03
   Gosub Civ_print4_1a0500
Return
17B:
   Civ_cmd4 = &H04
   Gosub Hpf_lpf
Return
17C:
   Civ_cmd4 = &H04
   Gosub Civ_print4_1a0500
Return
17D:
   B_temp1 = 11
   Civ_cmd4 = &H05
   Gosub Civ_print_l_5_1a0500_bcd
Return
17E:
   Civ_cmd4 = &H05
   Gosub Civ_print4_1a0500
Return
17F:
   B_temp1 = 11
   Civ_cmd4 = &H06
   Gosub Civ_print_l_5_1a0500_bcd
Return