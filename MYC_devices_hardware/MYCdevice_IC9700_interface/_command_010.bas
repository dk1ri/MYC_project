' Command 100 - 11F
' 20100225
'
100:
   If Commandpointer >= 6 Then
      B_temp4 = 2
      Frequenz_b(4) = Command_b(3)
      Frequenz_b(3) = Command_b(4)
      Frequenz_b(2) = Command_b(5)
      Frequenz_b(1) = Command_b(6)
      If Frequenz < 2000000 Then
         Frequenz_adder = 144000000
         Gosub S_frequency
      Else
         If Frequenz > 22000000 Then
            Frequenz_adder = 428000000
            Gosub S_frequency
         Else
            If Frequenz > 82000000 Then
               Frequenz_adder = 1218000000
               Gosub S_frequency
            Else
               Parameter_error
               Gosub Command_received
            End If
         End If
      End If
      If Temps <> "" Then
         Temps_b(1) = &H00
         Civ_len = 7
         Gosub Civ_print
      End If
   End If
Return
'
101:
   Temps = "{003}"
   Civ_len = 1
   Gosub Civ_print
Return
'
102:
   If Commandpointer >= 4 Then
      If Command_b(3) < 8 And Command_b(4) < 3 Then
         Temps_b(1) = &H06
         B_temp1 = Command_b(3)
         If b_Temp1 > 5 Then Incr B_temp1
         If b_Temp1 = 8 Then B_temp1 = &H17
         If b_Temp1 > 5 Then B_temp1 = &H22
         Temps_b(2) = B_temp1
         B_temp1 = Command_b(4) + 1
         Temps_b(3) = B_temp1
         Civ_len = 3
         Gosub Civ_print
         Operating_mode = Temps_b(2)
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
103:
   Temps = "{004}"
   Civ_len = 1
   Gosub Civ_print
Return
'
104:
   Temps_b(1) = &H02
   Civ_len = 1
   Gosub Civ_print
Return
'
105:
   Temps = "{007}"
   Civ_len = 1
   Gosub Civ_print
   Vfo_mem = 0
Return
'
106:
   If Commandpointer >= 3 Then
      If Command_b(3) < 4 Then
         b_temp1 = Command_b(3)
         If b_Temp1 = 2 Then b_Temp1 = &HA0
         If b_Temp1 = 3 Then b_Temp1 = &HB0
         Temps_b(1) = &H07
         Temps_b(2) = B_temp1
         Civ_len = 2
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
107:
   If Commandpointer >= 3 Then
      If Command_b(3) < 2 Then
         Temps_b(1) = &H07
         Temps_b(2) = &HD2
         Temps_b(3) = Command_b(3)
         Civ_len = 3
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
108:
   Temps = Chr(&H07) + Chr(&HD2)
   Civ_len = 2
   Gosub Civ_print
Return
'
109:
   Temps = "{008}"
   Civ_len = 1
   Gosub Civ_print
   Vfo_mem = 1
Return
'
10A:
   If Commandpointer >= 3 Then
      If Command_b(3) < 107 Then
         If Command_b(3) < 99 Then
            b_Temp1 = 0
            B_temp2 = Command_b(3) + 1
            b_Temp2 = Makebcd(B_temp2)
         Else
            b_Temp1 = 1
            b_Temp2 = Command_b(3) - 99
         End If
         Temps_b(1) = &H08
         Temps_b(2) = B_temp1
         Temps_b(3) = B_temp2
         Civ_len = 3
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
10B:
   Temps = "{009}"
   Civ_len = 1
   Gosub Civ_print
Return
'
10C:
   Temps = "{010}"
   Civ_len = 1
   Gosub Civ_print
Return
'
10D:
   Temps = "{011}"
   Civ_len = 1
   Gosub Civ_print
Return
'
10E:
   If Commandpointer >= 5 Then
      Frequenz_b(4) = Command_b(3)
      Frequenz_b(3) = Command_b(4)
      Frequenz_b(2) = Command_b(5)
      Frequenz_b(1) = 0
      If Frequenz < 1000000 Then
         B_temp1 = Frequenz / 10000
         Temps_b(4) = B_temp1
         Frequenz = Frequenz Mod 10000
         B_temp1 = Frequenz / 100
         Temps_b(3) = B_temp1
         Temps_b(2) = Frequenz Mod 100
         Temps_b(1) = &H0C
         Civ_len = 4
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
10F:
   Temps = Chr(&H0D)
   Civ_len = 1
   Gosub Civ_print
Return
'
110:
   If Commandpointer >= 3 Then
      If Command_b(3) < 9 Then
         If Command_b(3) > 5 And Vfo_mem = 0 Then
            Parameter_error
            Gosub Command_received
         Else
            Select Case Command_b(3)
               Case 0 to 3
                  b_Temp1 = Command_b(3)
               Case 4 to 5
                  b_Temp1 = Command_b(3) + 14
                  '12 13
               Case 6 to 8
                  b_Temp1 = Command_b(3) + 28
            End Select
            Temps_b(1) = &H0E
            Temps_b(2) = B_temp1
            Civ_len = 2
            Gosub Civ_print
         End If
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
111:
   If Commandpointer >= 3 Then
      If Command_b(3) < 7 Then
         b_Temp1 = Command_b(3) + &HA1
         Temps_b(1) = &H0E
         Temps_b(2) = B_temp1
         Civ_len = 2
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
112:
   Temps_b(1) = &H0E
   Temps_b(2) = &HB0
   Civ_len = 2
   Gosub Civ_print
Return
'
113:
   If Commandpointer >= 3 Then
      If Command_b(3) < 3 Then
         Temps_b(1) = &H0E
         Temps_b(2) = &HB1
         Civ_len = 3
         Temps_b(3) = Command_b(3) + 1
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
114:
   If Commandpointer >= 3 Then
      If Command_b(3) < 3 Then
         Temps_b(1) = &H0E
         Temps_b(2) = &HB2
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
115:
   If Commandpointer >= 3 Then
      If Command_b(3) < 2 Then
         Temps_b(1) = &H0E
         If Command_b(3) = 0 Then
            Temps_b(2) =  &HD0
         Else
            Temps_b(2) = &HD3
         End If
         Civ_len = 2
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
116:
   If Commandpointer >= 3 Then
      If Command_b(3) < 6 Then
         Temps_b(1) = &H0F
         Temps_b(2) = Command_b(3)
         If Command_b(3) > 1 Then Temps_b(2) = Temps_b(2) + &H0E
         Civ_len = 2
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
117:
   Temps_b(1) = &H0F
   Civ_len = 1
   Gosub Civ_print
Return
'
118:
   If Commandpointer >= 3 Then
      If Command_b(3) < 12 Then
         Temps_b(1) = &H10
         Temps_b(2) = Makebcd(Command_b(3) + 1)
         Civ_len = 2
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
119:
   Temps_b(1) = &H10
   Civ_len = 1
   Gosub Civ_print
Return
'
11A:
   If Commandpointer >= 3 Then
      If Command_b(3) < 2 Then
         Temps_b(1) = &H11
         B_temp1 = &H00
         If Command_b(3) = 1 Then B_temp1 = &H10
         Temps_b(2) = B_temp1
         Civ_len = 2
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
11B:
   Temps_b(1) = &H11
   Civ_len = 1
   Gosub Civ_print
Return
'
11C:
   If Commandpointer >= 3 Then
      If Command_b(3) < 3 Then
         Temps_b(1) = &H13
         Temps_b(2) = Command_b(3)
         Civ_len = 2
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
Return
'
11D:
   CiV_cmd1 = &H14
   Civ_cmd2 = &H01
   Gosub Civ_print_255_4_bcd
Return
'
11E:
   Temps = Chr(&H14) + Chr(&H01)
   Civ_len = 2
   Gosub Civ_print
   Return
'
11F:
   CiV_cmd1 = &H14
   Civ_cmd2 = &H02
   Gosub Civ_print_255_4_bcd
   Return
'