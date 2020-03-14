' Command 100 - 11F
' 20200216
'
100:
   If Commandpointer >= 6 Then
      D_temp1 = Command_b(3) * 16777216
      Temp_dw1 = Command_b(4) * 65536
      D_temp1 = D_temp1 + Temp_dw1
      Temp_dw1 = Command_b(5) * 256
      D_temp1 = D_temp1 + Temp_dw1
      D_temp1 = D_temp1 + Command_b(6)
      If D_temp1 < 199970000 Then
         D_temp2 = 199970000
      Else
         D_temp1 = D_temp1 + 400000000
         Command_b(3) = D_temp1.4
         Command_b(4) = D_temp1.3
         Command_b(5) = D_temp1.2
         Command_b(6) = D_temp1.1
         D_temp2 = 469070000
      End If
         B_temp5 = 2
         B_temp4 = 2
         Gosub S_frequency
      If Temps <> "" Then
         Temps_b(1) = &H00
         Civ_len = 6
         Gosub Civ_print
      Else
         Parameter_error
      End If
      Gosub Command_received
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
         If b_Temp1 > 5 Then Incr b_Temp1
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
         If B_temp1 = 2 Then B_temp1 = &HA0
         If B_temp1 = 3 Then B_temp1 = &HB0
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
   Temps = "{008}"
   Civ_len = 1
   Gosub Civ_print
   Vfo_mem = 1
   Return
'
108:
   If Commandpointer >= 3 Then
      If Command_b(3) < 107 Then
         If Command_b(3) < 99 Then
            B_temp1 = 0
            B_temp2 = Command_b(3) + 1
            B_Temp2 = Makebcd(B_temp2)
         Else
            b_Temp1 = 1
            B_Temp2 = Command_b(3)
            B_Temp2 = B_Temp2 - 99
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
109:
   If Commandpointer >= 3 Then
      If Command_b(3) < 5 Then
         Temps_b(1) = &H08
         Temps_b(2) = &HA0
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
10A:
   Temps = "{009}"
   Civ_len = 1
   Gosub Civ_print
   Return
'
10B:
   Temps = "{010}"
   Civ_len = 1
   Gosub Civ_print
   Return
'
10C:
   Temps = "{011}"
   Civ_len = 1
   Gosub Civ_print
   Return
'
10D:
   If Commandpointer >= 4 Then
   Temps_b(1) = &H0D
   W_temp1_h = Command_b(3)
   W_temp1_l = Command_b(4)
   If W_temp1 < 1000000 Then
      Temp_dw1 = Temp_dw / 10000
      B_temp2 = Temp_dw1
      Temps_b(4) = Makebcd(B_temp2)
      W_temp1 = W_temp1 Mod 10000
      Temp_dw1 = W_temp1 / 100
      B_temp2 = Temp_dw1
      Temps_b(3) = Makebcd(B_temp2)
      W_temp1 = W_temp1 Mod 100
      B_temp2 = W_temp1
      Temps_b(2) = Makebcd(B_temp2)
      Civ_len = 4
      Gosub Civ_print
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return
'
10E:
   Temps = "{012}"
   Civ_len = 1
   Gosub Civ_print
   Return
'
10F:
   If Commandpointer >= 3 Then
      If Command_b(3) < 5 Then
         Temps_b(1) = &H0E
         Temps_b(2) = Command_b(2)
         If Temps_b(2) > 2 Then Temps_b(2) = Temps_b(2) + &H1F
         Civ_len = 2
         Gosub Civ_print
      Else
         Parameter_error
         Gosub Command_received
      End If
   End If
   Return
'
110:
   Temps_b(1) = &H0E
   Temps_b(2) = &HB0
   Civ_len = 2
   Gosub Civ_print
   Return
'
111:
   Temps_b(1) = &H0E
   Temps_b(2) = &HB1
   Civ_len = 2
   Gosub Civ_print
   Return
'
112:
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
113:
   If Commandpointer >= 3 Then
      If Command_b(3) < 5 Then
         Temps_b(1) = &H0F
         If Command_b(3) > 1 Then Command_b(3) = Command_b(3) + 14
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
114:
   If Commandpointer >= 3 Then
      If Command_b(3) < 11 Then
         Temps_b(1) = &H10
         Temps_b(2) = Makebcd(Command_b(3))
         Civ_len = 2
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
         Temps_b(1) = &H11
         B_temp1 = &H00
         If Command_b(3) = 1 Then B_temp1 = &H12
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
116:
   Temps_b(1) = &H11
   Civ_len = 1
   Gosub Civ_print
   Return
'
117:
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
118:
   CiV_cmd1 = &H14
   Civ_cmd2 = &H01
   Gosub Civ_print_255_4_bcd
   Return
'
119:
   Temps = Chr(&H14) + Chr(&H01)
   Civ_len = 2
   Gosub Civ_print
   Return
'
11A:
   Civ_cmd4 = &H01
   Gosub Civ_print_255_5_1a0500
   Return
'
11B:
   Temps = Chr(&H14) + Chr(&H02)
   Civ_len = 2
   Gosub Civ_print
   Return
'
11C:
   CiV_cmd1 = &H14
   Civ_cmd2 = &H03
   Gosub Civ_print_255_4_bcd
   Return
'
11D:
   Temps = Chr(&H14) + Chr(&H03)
   Civ_len = 2
   Gosub Civ_print
   Return
'
11E:
   CiV_cmd1 = &H14
   Civ_cmd2 = &H06
   Gosub Civ_print_255_4_bcd
   Return
'
11F:
   Temps = Chr(&H14) + Chr(&H06)
   Civ_len = 2
   Gosub Civ_print
   Return
'