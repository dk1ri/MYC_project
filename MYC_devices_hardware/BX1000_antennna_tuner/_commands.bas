' Commands
' 20230924
'
01:
If Commandpointer >= 3 Then
   If Command_b(2) < 11 And Command_b(3) < 2 Then
      If Config_value  < 3 Then
         If Drive_enable = 1 Then
            B_temp1 = High(L_value)
            B_temp2 = Low(L_value)
            B_temp3 = Command_b(2)
            If B_temp3 < 8 Then
               B_temp2.B_temp3 = Command_b(3)
            Else
               B_temp3 = B_temp3 - 8
               B_temp1.B_temp3 = Command_b(3)
            End If
            L_value = B_temp1 * 256
            L_value = L_value + B_temp2
            If L_value <> L_value_old Then
               Gosub Set_l_drive
               Gosub Send_data
               L_value_old = L_value
            End If
         Else
            Power_too_high
         End If
      Else
         Not_valid_at_this_time
      End If
  Else
     Parameter_error
  End If
  Gosub Command_received
End If
Return
'
02:
Tx_b(1) = &H02
W_temp2 = 0
B_temp2 = High(L_value)
For B_temp1 = 2 to 0 Step -1
   If B_temp2.B_temp1 = 1 Then
      Select Case B_temp1
         Case 2:
            W_temp1 = 32200
         Case 1:
            W_temp1 = 16400
         Case 0:
            W_temp1 = 8400
      End Select
      W_temp2 = W_temp2 + W_temp1
   End If
Next B_temp1
B_temp2 = Low(L_value)
For B_temp1 = 7 to 0 Step -1
      If B_temp2.B_temp1 = 1 Then
         Select Case B_temp1
            Case 7:
               W_temp1 = 4300
            Case 6:
               W_temp1 = 2200
            Case 5:
               W_temp1 = 1120
            Case 4:
               W_temp1 = 580
            Case 3:
               W_temp1 = 300
            Case 2:
               W_temp1 = 150
            Case 1:
               W_temp1 = 80
            Case 0:
               W_temp1 = 40
         End Select
         W_temp2 = W_temp2 + W_temp1
   End If
Next B_temp1
Tx_b(2) = High(W_temp2)
Tx_b(3) = Low(W_temp2)
Tx_write_pointer = 4
Gosub Print_tx
Gosub Command_received
Return
'
03:
If Commandpointer >= 3 Then
   If Command_b(2) < 12 And Command_b(3) < 2 Then
      If Config_value  < 3 Then
          If Drive_enable = 1 Then
             B_temp1 = High(C_value)
             B_temp2 = Low(C_value)
             B_temp3 = Command_b(2)
             If B_temp3 < 8 Then
                B_temp2.B_temp3 = Command_b(3)
             Else
                B_temp3 = B_temp3 - 8
                B_temp1.B_temp3 = Command_b(3)
             End If
             C_value = B_temp1 * 256
             C_value = C_value + B_temp2
             If C_value <> C_value_old Then
                Gosub Set_C_drive
                Gosub Send_data
                C_value_old = C_value
             End If
          Else
             Power_too_high
          End If
      Else
         Not_valid_at_this_time
      End If
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return
'
04:
Tx_b(1) = &H04
W_temp2 = 0
B_temp2 = High(C_value)
For B_temp1 = 3 to 0 Step -1
   If B_temp2.B_temp1 = 1 Then
      Select Case B_temp1
         Case 3:
            W_temp1 = 3600
         Case 2
            W_temp1 = 1860
         Case 1:
            W_temp1 = 960
         Case 0:
            W_temp1 = 500
      End Select
      W_temp2 = W_temp2 + W_temp1
   End If
Next B_temp1
B_temp2 = Low(C_value)
For B_temp1 = 7 to 0 Step -1
   If B_temp2.B_temp1 = 1 Then
      Select Case B_temp1
         Case 7:
            W_temp1 = 280
         Case 6:
            W_temp1 = 150
         Case 5:
            W_temp1 = 78
         Case 4:
            W_temp1 = 40
         Case 3:
            W_temp1 = 20
         Case 2:
            W_temp1 = 10
         Case 1:
            W_temp1 = 5
         Case 0:
            W_temp1 = 2
      End Select
      W_temp2 = W_temp2 + W_temp1
   End If
Next B_temp1
Tx_b(2) = High(W_temp2)
Tx_b(3) = Low(W_temp2)
Tx_write_pointer = 4
Gosub Print_tx
Gosub Command_received
Return
'
05:
If Commandpointer >= 2 Then
   If Command_b(2) < 4 Then
      If Drive_enable = 1 Then
         Config_value = Command_b(2)
         If Config_value = 3 Then
            Up_down_step = 0
         End If
         If Config_value <> Config_value_old Then
            If Config_value = 3  Then
               L_value_last = L_value
               L_value = 0
               Gosub Set_L_drive
               ' c is switched off
            Else
               If Last_config = 3 Then
                  L_value = L_value_last
                  Gosub Set_L_drive
               End If
            End If
            Gosub Set_Config_drive
            Gosub Send_data
            Config_value_old = Config_value
         End If
         Last_config = Config_value
      Else
        Power_too_high
      End If
   Else
     Parameter_error
  End If
  Gosub Command_received
End If
Return
'
06:
Tx_b(1) = &H06
Tx_b(2) = Config_value
Tx_write_pointer = 3
Gosub Print_tx
Gosub Command_received
Return
'
07:
If Commandpointer >= 3 Then
   If Command_b(2) < 4 And Command_b(3) < 2 Then
       'set the bits of the byte Relais-positios
      B_temp1 = Command_b(2)
      Relais_value.B_temp1 = Command_b(3)
      If Relais_value <> Relais_value_old Then
         Relais_value_eram = Relais_value
         Gosub Set_relais_drive
         Gosub Send_data
         Relais_value_old = Relais_value
      End If
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return
'
08:
Tx_b(1) = &H08
Tx_b(2) = 4
B_temp3 = 3
For B_temp1 = 3 to 1 Step -1
   If Relais_value.B_temp1 = 0 Then
      Tx_b(B_temp3) = "_"
   Else
      Tx_b(B_temp3) = "X"
   End If
   Incr B_temp3
Next B_temp1
Tx_write_pointer = 7
Gosub Print_tx
Gosub Command_received
Return
'
09:
If Commandpointer >= 2 Then
   If Command_b(2) < 6 Then
       If Config_value  < 3 Then
          Up_down = 0
          Up_down_step = Command_b(2)
       Else
         Not_valid_at_this_time
       End If
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return
'
10:
If Commandpointer >= 2 Then
   If Command_b(2) < 6 Then
      If Config_value  < 3 Then
          Up_down = 1
          Up_down_step = Command_b(2)
      Else
         Not_valid_at_this_time
      End If
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return
'
11:
If Commandpointer >= 2 Then
   If Command_b(2) < 6 Then
      If Config_value  < 3 Then
         Up_down = 2
         Up_down_step = Command_b(2)
      Else
         Not_valid_at_this_time
      End If
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return
'
12:
If Commandpointer >= 2 Then
   If Command_b(2) < 6 Then
      If Config_value  < 3 Then
         Up_down = 3
         Up_down_step = Command_b(2)
      Else
         Not_valid_at_this_time
      End If
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return
'
13:
Tx_b(1)= &H0D
If Up_down_step < 2 Then
   Tx_b(2) = 0
Else
   Tx_b(2) = Up_down + 1
End If
Tx_write_pointer = 3
Gosub Print_tx
Gosub Command_received
Return
'
14:
Tx_b(1) = &H0E
W_temp1 = Fwd
Gosub Find_fwd_rev
Tx_b(2) = High(W_temp1)
Tx_b(3) = Low(W_temp1)
Tx_write_pointer = 4
Gosub Print_tx
Gosub Command_received
Return
':
15:
Tx_b(1) = &H0F
W_temp1 = Rev
Gosub Find_fwd_rev
Tx_b(2) = High(W_temp1)
Tx_b(3) = Low(W_temp1)
Tx_write_pointer = 4
Gosub Print_tx
Gosub Command_received
Return
'
16:
Tx_b(1) = &H10
W_temp1 = Fwd
Gosub Find_fwd_rev
Fwd = W_temp1
'
W_temp1 = Rev
Gosub Find_fwd_rev
Rev = W_temp1
W_temp1 = Fwd + Rev
If Fwd > Rev Then
   W_temp2 = Fwd - Rev
   If W_temp1 > 0 Then
      Tempsingle = W_temp1 / W_temp2
      If Tempsingle > 25 Then Tempsingle = 25
      Swr = Tempsingle * 10
   Else
      Swr = 0
   End If
Else
   'sometimes Rev > Fed: ??? -> Swr high
   Swr = 25
End If
Tx_b(2) = Swr
Tx_write_pointer = 3
Gosub Print_tx
Gosub Command_received
Return
'
17:
If Commandpointer >= 3 Then
   W_temp1 = Command_b(2) * 256
   W_temp1 = W_temp1 + Command_b(3)
   If W_temp1 < 26101  Then
      Frequency = W_temp1 + 1800
      Gosub Find_chanal_number_band
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return
'
18:
Tx_b(1)= &H12
W_temp1 = Frequency - 1800
Tx_b(2) = High(W_temp1)
Tx_b(3) = Low(W_temp1)
'For B_temp1 = 1 to 10
'   W_temp1= Cou(B_temp1)
'   B_temp2 = B_temp1 * 2
'   B_temp2 = B_temp2 + 2
'   Tx_b(B_temp2) = High(W_temp1)
'   Incr B_temp2
'   Tx_b(B_temp2) = Low(W_temp1)
'Next B_temp1
Tx_write_pointer = 4
Gosub Print_tx
Gosub Command_received
Return
'
19:
Tx_b(1)= &H13
W_temp1 = Chanal_number - 1
Tx_b(2) = High(W_temp1)
Tx_b(3) = Low(W_temp1)
Tx_write_pointer = 4
Gosub Print_tx
Gosub Command_received
Return
'
20:
Tx_b(1)= &H14
Tx_b(2) = Band - 1
Tx_write_pointer = 3
Gosub Print_tx
Gosub Command_received
Return
'
21:
W_temp1 = L_value
'Set
W_temp1.15 = 1
L_pos(Chanal_number) = W_temp1
' Add Config
B_temp1 = High(Config_value)
If B_temp1.1 = 0 Then
   C_value.15 = 0
Else
   C_value.15 = 1
End If
If B_temp1.0 = 0 Then
   C_value.14 = 0
Else
   C_value.14 = 1
End If
C_pos(Chanal_number) = C_value
Gosub Command_received
Return
'
22:
W_temp1 = L_pos(Chanal_number)
B_temp1 = High(W_temp1)
If B_temp1.7 = 1 Then
   L_value = L_pos(Chanal_number) And &B0001111111111111
   Gosub Set_l_drive
   C_value = C_pos(Chanal_number) And &B0011111111111111
   Gosub Set_C_drive
   W_temp1 = C_pos(Chanal_number) And &B1100000000000000
   Config_value = W_temp1
   Gosub Set_config_drive
   Gosub Send_data
Else
   Gosub Interpolate
End If
Gosub Command_received
Return
'
23:
L_pos(Chanal_number) = L_default
C_pos(Chanal_number) = C_default
' config is default
Gosub Command_received
Return
'
24:
If Config_value  < 3 Then
   If Drive_enable = 1 Then
      L_value_old = L_value
      L_value = L_default
      C_value_old = C_value
      C_value = C_default
      Config_value_old = Config_value
      Config_value = 0
      Gosub Set_L_drive
      Gosub Set_C_drive
      Gosub Set_config_drive
      Gosub Send_data
   Else
      Power_too_high
   End If
Else
   Not_valid_at_this_time
End If
Gosub Command_received
Return
'
25:
If Commandpointer >= 3 Then
   If Command_b(2) < 2  Then
      If Command_b(2) = 1 Then
         Set Cool
         Force_fan = 1
      Else
         Force_fan = 0
      End If
   Else
     Parameter_error
   End If
   Gosub Command_received
End If
Return
'
26:
Tx_b(1) = &H1A
Tx_b(2) = Cool
Tx_write_pointer = 3
Gosub Print_tx
Gosub Command_received
Return
'
27:
' 15V -> 5V after R divider
' this is full scale -> 1024
Tx_b(1) = &H1B
W_temp1 =Getadc(3)
Tempsingle = W_temp1
Tempsingle = Tempsingle * 1500
Tempsingle = Tempsingle / 1024
W_temp1 = Tempsingle
Tx_b(2) = High(W_temp1)
Tx_b(3) = Low(W_temp1)
Tx_write_pointer = 4
Gosub Print_tx
Gosub Command_received
Return
'
28:
'  NTC 10kOhm  / 4k7 to 5V
' B25_50 = 390; B25_50 = 3980; B25_100 = 4000
Restore Ntc
B_temp1 = 0
B_temp2 = 0
B_temp3 = 0
While B_temp2 = 0
   Read Temp_i1
   If Temp_i1 < Ntc_value Then B_temp2 = 1
   Incr B_temp1
   If B_temp1 > 100 Then B_temp2 = 1
   Incr B_temp3
Wend
Tx_b(1) = &H1C
Tx_b(2) = B_temp1
Tx_write_pointer = 3
Gosub Print_tx
Gosub Command_received
Return
'