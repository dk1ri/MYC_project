' Command 160 - 17F
' 20200217
'
160:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H4C
   B_temp1 = 2
   Gosub Civ_print_l_3
Return
'
161:
   Temps = Chr(&H16) + Chr(&H4C)
   Civ_len = 2
   Gosub Civ_print
Return
'
162:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H4F
   B_temp1 = 2
   Gosub Civ_print_l_3
Return
'
163:
   Temps = Chr(&H16) + Chr(&H4F)
   Civ_len = 2
   Gosub Civ_print
Return
'
164:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H50
   B_temp1 = 3
   Gosub Civ_print_l_3
Return
'
165:
   Temps = Chr(&H16) + Chr(&H50)
   Civ_len = 2
   Gosub Civ_print
Return
'
166:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H51
   B_temp1 = 2
   Gosub Civ_print_l_3
Return
'
167:
    Temps = Chr(&H16) + Chr(&H51)
   Civ_len = 2
   Gosub Civ_print
Return
'
168:
    Temps = Chr(&H19)
   Civ_len = 1
   Gosub Civ_print
Return
'
169:
' memory content unknown !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   If Commandpointer >= 3 Then
      If Command_b(3) < 103 Then
         Temps = Chr(&H1A) + Chr(&H00)
         If Command_b(3) < 100 Then
            Temps_b(3) = 0
            Temps_b(4) = Command_b(3)
         Else
            Temps_b(3) = 1
            Temps_b(4) = Command_b(3) - 100
         End If
         Civ_len = 4
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
16A:
   If Commandpointer >= 3 Then
      If Command_b(3) < 103 Then
         Temps = Chr(&H1A) + Chr(&H00)
         If Command_b(3) < 100 Then
            Temps_b(3) = 0
            Temps_b(4) = Command_b(3)
         Else
            Temps_b(3) = 1
            Temps_b(4) = Command_b(3) - 100
         End If
         Civ_len = 4
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
16B:
' bandstack? sh 7300
   If Commandpointer >= 8 Then
      If Command_b(3) < 13 And Command_b(4) < 3 Then
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
16C:
   If Commandpointer >= 4 Then
      If Command_b(3) < 13 And Command_b(4) < 3 Then
         Temps = Chr(&H1A) + Chr(&H01)
         Temps_b(3) = Command_b(3) + 1
         Temps_b(4) = Command_b(4) + 1
         Civ_len = 4
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
16D:
   If Commandpointer >= 4 Then
      If Command_b(3) < 4 Then
         B_temp1 = Command_b(4)
         If B_temp1 > 0 Then
            If B_temp1 < 71 Then
               B_temp2 = B_temp1 + 4
               If Commandpointer >= B_temp2 Then
                  Incr Command_b(3)
                  Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00)  + Chr(&H02)
                  Temps_b(4) = Command_b(3)
                  For B_temp2 = 1 To B_temp1
                     Temps_b(B_temp2 + 5) = Command_b(B_temp2 + 4)
                  Next B_temp2
                  Civ_len = B_temp1 + 5
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
16E:
   If Commandpointer >= 3 Then
      If Command_b(3) < 4 Then
         Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H02)
         Temps_b(5) = Command_b(3) + 1
         Civ_len = 3
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
16F:
   If Operating_mode = 2 Then
      Civ_cmd2 = &H03
      B_temp1 = 50
      Gosub Civ_print_l_3_1a
   Else
      Parameter_error
   End If
Return
'
170:
   If Operating_mode = 2 Then
      Temps = Chr(&H1A) + Chr(&H03)
      Civ_len = 2
      Last_command = &H70
      Gosub Civ_print
   Else
      Parameter_error
   End If
Return
'
171:
   If Operating_mode <> 2 Then
      Civ_cmd2 = &H03
      B_temp1 = 50
      Gosub Civ_print_l_3_1a
   Else
      Parameter_error
   End If
Return
'
172:
   If Operating_mode <> 2 Then
      Temps = Chr(&H1A) + Chr(&H03)
      Civ_len = 2
      Last_command = &H72
      Gosub Civ_print
   Else
      Parameter_error
   End If
Return
'
173:
   If Operating_mode = 2 Then
      Civ_cmd2 = &H04
      B_temp1 = 14
      Gosub Civ_print_l_3_1a
   Else
      Parameter_error
   End If
Return
'
174:
   If Operating_mode = 2 Then
      Temps = Chr(&H1A) + Chr(&H04)
      Civ_len = 2
      Last_command = &H74
      Gosub Civ_print
   Else
      Parameter_error
   End If
Return
'
175:
   If Operating_mode <> 2 Then
      Civ_cmd2 = &H04
      B_temp1 = 14
      Gosub Civ_print_l_3_1a
   Else
      Parameter_error
   End If
Return
'
176:
   If Operating_mode <> 2 Then
      Temps = Chr(&H1A) + Chr(&H04)
      Civ_len = 2
      Last_command = &H76
      Gosub Civ_print
   Else
      Parameter_error
   End If
Return
'
177:
   B_temp1 = 3
   Civ_cmd4 = &H03
   Gosub Civ_print_l_5_1a0500
Return
'
178:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H03)
   Civ_len = 4
   Gosub Civ_print
Return
'
179:
   B_temp1 = 3
   Civ_cmd4 = &H04
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
17A:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H04)
   Civ_len = 4
   Gosub Civ_print
Return
'
17B:
   B_temp1 = 3
   Civ_cmd4 = &H05
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
17C:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H05)
   Civ_len = 4
   Gosub Civ_print
Return
'
17D:
   B_temp1 = 3
   Civ_cmd4 = &H06
   Gosub Civ_print_l_5_1a0500_bcd
Return
'
17E:
   Temps = Chr(&H1A) + Chr(&H05) + Chr(&H00) + Chr(&H06)
   Civ_len = 4
   Gosub Civ_print
Return
'
17F:
   B_temp1 = 3
   Civ_cmd4 = &H07
   Gosub Civ_print_l_5_1a0500_bcd
Return
'