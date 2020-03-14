' Command 160 - 17F
' 20200225
'
160:
   Temps = Chr(&H16) + Chr(&H47)
   Civ_len = 2
   Gosub Civ_print
Return
'
161:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H48
   B_temp1 = 2
   Gosub Civ_print_l_3
Return
'
162:
   Temps = Chr(&H16) + Chr(&H48)
   Civ_len = 2
   Gosub Civ_print
Return
'
163:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H4A
   B_temp1 = 2
   Gosub Civ_print_l_3
Return
'
164:
   Temps = Chr(&H16) + Chr(&H4A)
   Civ_len = 2
   Gosub Civ_print
Return
'
165:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H4B
   B_temp1 = 2
   Gosub Civ_print_l_3
Return
'
166:
   Temps = Chr(&H16) + Chr(&H4B)
   Civ_len = 2
   Gosub Civ_print
Return
'
167::
   Civ_cmd1 = &H16
   Civ_cmd2 = &H4F
   B_temp1 = 2
   Gosub Civ_print_l_3
Return
'
168:
   Temps = Chr(&H16) + Chr(&H4F)
   Civ_len = 2
   Gosub Civ_print
Return
'
169:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H50
   B_temp1 = 2
   Gosub Civ_print_l_3
Return

16A:
   Temps = Chr(&H16) + Chr(&H50)
   Civ_len = 2
   Gosub Civ_print
Return
'
16B:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H56
   B_temp1 = 2
   Gosub Civ_print_l_3
Return

16C:
   Temps = Chr(&H16) + Chr(&H56)
   Civ_len = 2
   Gosub Civ_print
Return
'
16D:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H57
   B_temp1 = 3
   Gosub Civ_print_l_3
Return

16E:
   Temps = Chr(&H16) + Chr(&H57)
   Civ_len = 2
   Gosub Civ_print
Return
'
16F:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H58
   B_temp1 = 3
   Gosub Civ_print_l_3
Return
'
170:
   Temps = Chr(&H16) + Chr(&H58)
   Civ_len = 2
   Gosub Civ_print
Return
'
171:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H59
   B_temp1 = 2
   Gosub Civ_print_l_3
Return
'
172:
   Temps = Chr(&H16) + Chr(&H59)
   Civ_len = 2
   Gosub Civ_print
Return
'
173:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H5A
   B_temp1 = 2
   Satellite_mode = command_b(3)
   Gosub Civ_print_l_3
Return
'
174:
   Temps = Chr(&H16) + Chr(&H5A)
   Civ_len = 2
   Gosub Civ_print
Return
'
175:
   If Operating_mode = &H17 Then
      Civ_cmd1 = &H16
      Civ_cmd2 = &H5B
      B_temp1 = 3
      Satellite_mode = command_b(3)
      Gosub Civ_print_l_3
   Else
      Parameter_error
   End If
Return
'
176:
   Temps = Chr(&H16) + Chr(&H5B)
   Civ_len = 2
   Gosub Civ_print
Return
'
177:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H5C
   B_temp1 = 3
   Gosub Civ_print_l_3
Return
'
178:
   Temps = Chr(&H16) + Chr(&H5C)
   Civ_len = 2
   Gosub Civ_print
Return
'
179:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H5D
   B_temp1 = 8
   Gosub Civ_print_l_3
Return
'
17A:
   Temps = Chr(&H16) + Chr(&H5D)
   Civ_len = 2
   Gosub Civ_print
Return
'
17B:
   Civ_cmd1 = &H16
   Civ_cmd2 = &H65
   B_temp1 = 2
   Gosub Civ_print_l_3
Return
'
17C:
   Temps = Chr(&H16) + Chr(&H65)
   Civ_len = 2
   Gosub Civ_print
Return
'
17D:
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
'
17E:
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
'
17F:
   Temps = Chr(&H19)
   Temps_b(2) = &H00
   Civ_len = 2
   Gosub Civ_print
Return
'