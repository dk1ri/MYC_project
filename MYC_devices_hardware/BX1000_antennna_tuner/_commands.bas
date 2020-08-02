' Commands
' 20200730
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
            Start_send_data = 0
            Up_down = 0
            If L_value <> L_value_old Then
               Gosub Set_l_drive
               Gosub Send_data
               L_value_old = L_value
            End If
         Else
            Power_too_high
         End If
      Else
         Command_not_found
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
Tx_b(2) = High(L_value)
Tx_b(3) = Low(L_value)
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
             Start_send_data = 0
             Up_down = 0
             If C_value <> C_value_old Then
                Gosub Set_C_drive
                Gosub Send_data
                C_value_old = C_value
             End If
          Else
             Power_too_high
          End If
      Else
         Command_not_found
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
Tx_b(2) = High(C_value)
Tx_b(3) = Low(C_value)
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
         If Config_value <> Config_value_old Then
            If Config_value = 3 Then
               Up_down = 0
               L_value_save = L_value
               L_value = 0
               Gosub Set_l_drive
               L_value_old = L_value
            End If
            If Config_value_old = 3 Then
               L_value = L_value_save
               Gosub Set_l_drive
               L_value_old = L_value
            End If
            Gosub Set_Config_drive
            Gosub Send_data
            Config_value_old = Config_value
         End If
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
Tx_b(2) = Relais_value
Tx_write_pointer = 3
Gosub Print_tx
Gosub Command_received
Return
'
09:
If Commandpointer >= 2 Then
   If Config_value < 3 Then
      If Command_b(2) < 4 Then
         If Up_down = 1 Then
            Up_down = 0
         Else
            Up_down = 1
            Up_down_step = Command_b(2)
         End If
      Else
         Parameter_error
      End If
   Else
      Command_not_found
   End If
Gosub Command_received
End If
Return
'
0A:
If Commandpointer >= 2 Then
   If Config_value < 3 Then
      If Command_b(2) < 4 Then
         If Up_down = 2 Then
            Up_down = 0
         Else
            Up_down = 2
            Up_down_step = Command_b(2)
         End If
      Else
         Parameter_error
      End If
   Else
      Command_not_found
   End If
Gosub Command_received
End If
Return
'
0B:
If Commandpointer >= 2 Then
   If Config_value < 3 Then
      If Command_b(2) < 4 Then
         If Up_down = 3 Then
            Up_down = 0
         Else
            Up_down = 3
            Up_down_step = Command_b(2)
         End If
      Else
         Parameter_error
      End If
   Else
      Command_not_found
   End If
Gosub Command_received
End If
Return
'
0C:
If Commandpointer >= 2 Then
   If Config_value < 3 Then
      If Command_b(2) < 4 Then
         If Up_down = 4 Then
            Up_down = 0
         Else
            Up_down = 4
            Up_down_step = Command_b(2)
         End If
      Else
         Parameter_error
      End If
   Else
      Command_not_found
   End If
Gosub Command_received
End If
Return
'
0D:
Tx_b(1)= &H0D
Tx_b(2) = Up_down
Tx_write_pointer = 3
Gosub Print_tx
Gosub Command_received
Return
'
0E:
Tx_b(1) = &H0E
Tx_b(2) = High(Fwd)
Tx_b(3) = Low(Fwd)
Tx_write_pointer = 4
Gosub Print_tx
Gosub Command_received
Return
':
0F:
Tx_b(1) = &H0F
Tx_b(2) = High(Rev)
Tx_b(3) = Low(Rev)
Tx_write_pointer = 4
Gosub Print_tx
Gosub Command_received
Return
'
10:
Tx_b(1) = &H10
Tx_b(2) = Swr
Tx_write_pointer = 3
Gosub Print_tx
Gosub Command_received
Return
'
11:
If Commandpointer >= 3 Then
   W_temp1 = Command_b(2) * 256
   W_temp1 = W_temp1 + Command_b(3)
   If W_temp1 < 29701  Then
      Frequency = W_temp1
      Gosub Find_chanal_number_band
   Else
      Parameter_error
   End If
   Gosub Command_received
End If
Return
'
12:
Tx_b(1)= &H12
Tx_b(2) = High(Frequency)
Tx_b(3) = Low(Frequency)
Tx_write_pointer = 4
Gosub Print_tx
Gosub Command_received
Return
'
13:
Tx_b(1)= &H13
W_temp1 = Chanal_number - 1
Tx_b(2) = High(W_temp1)
Tx_b(3) = Low(W_temp1)
Tx_write_pointer = 4
Gosub Print_tx
Gosub Command_received
Return
'
14:
Tx_b(1)= &H14
Tx_b(2) = Band - 1
Tx_write_pointer = 3
Gosub Print_tx
Gosub Command_received
Return
'
15:
' set MSB of L_pos
B_temp1 = High(L_value)
B_temp1.7 = 1
B_temp2 = Low(L_value)
W_temp1 = B_temp1 * 256
W_temp1 = W_temp1 + B_temp2
L_pos(Chanal_number) = W_temp1
C_pos(Chanal_number) = C_value
' set Chanals up to bandend, if near
If Chanal_number < Pos_end(Band) Then
   W_temp2 = Pos_end(Band) - Chanal_number
   If W_temp2 < 2 Then
      W_temp1 = Chanal_number + 1
      If W_temp1 <= Pos_end(Band) Then
         B_temp1 = High(L_pos(W_temp1))
         If B_temp1.7 = 0 Then
            W_temp3 = L_pos(Chanal_number)
            L_pos(W_temp1) = W_temp3
            W_temp3 =  C_pos(Chanal_number)
            C_pos(W_temp1) = W_temp3
         End If
         W_temp1 = W_temp1 + 1
         If W_temp1 <= Pos_end(Band) Then
            B_temp1 = High(L_pos(W_temp1))
            If B_temp1.7 = 0 Then
               W_temp3 = L_pos(Chanal_number)
               L_pos(W_temp1) = W_temp3
               W_temp3 =  C_pos(Chanal_number)
               C_pos(W_temp1) = W_temp3
            End If
         End If
      End If
   End If
Else
   W_temp2 = Chanal_number - Pos_start(Band)
   If W_temp2 < 2 Then
      W_temp1 = Chanal_number - 1
      If W_temp1 >= Pos_start(Band) Then
         B_temp1 = High(L_pos(W_temp1))
         If B_temp1.7 = 0 Then
            W_temp3 = L_pos(Chanal_number)
            L_pos(W_temp1) = W_temp3
            W_temp3 =  C_pos(Chanal_number)
            C_pos(W_temp1) = W_temp3
         End If
         W_temp1 = W_temp1 + 1
         If W_temp1 >= Pos_start(Band) Then
            B_temp1 = High(L_pos(W_temp1))
            If B_temp1.7 = 0 Then
               W_temp3 = L_pos(Chanal_number)
               L_pos(W_temp1) = W_temp3
               W_temp3 =  C_pos(Chanal_number)
               C_pos(W_temp1) = W_temp3
            End If
         End If
      End If
   End If
End If
' store config_values
Config_pos(Band) = Config_value
Gosub Command_received
Return
'
16:
Config_value = Config_pos(Band)
W_temp1 = L_pos(Chanal_number)
B_temp1 = High(W_temp1)
If B_temp1.7 = 1 Then
   L_value = L_pos(Chanal_number)
   C_value = C_pos(Chanal_number)
Else
   Gosub Interpolate
End If
Gosub Set_l_drive
Gosub Set_c_drive
Gosub Set_config_drive
Gosub Send_data
Gosub Command_received
Return
'
17:
Gosub Eeram_default
Gosub Command_received
Return
'
18:
L_pos(Chanal_number) = L_default
C_pos(Chanal_number) = C_default
Gosub Command_received
Return
'
19:
If Commandpointer >= 3 Then
   If Command_b(2) < 2  Then
   Aux = Command_b(2)
      If Aux = 1 Then
         Set Cool
      Else
         If Force_fan = 0 Then Reset Cool
      End If
   Else
     Parameter_error
   End If
   Gosub Command_received
End If
Return
'
1A:
Tx_b(1) = &H1A
Tx_b(2) = Aux
Tx_write_pointer = 3
Gosub Print_tx
Gosub Command_received
Return
'
1B:
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
1C:
'  NTC 10kOhm  / 4k7 to 5V
' B25_50 = 390; B25_50 = 3980; B25_100 = 4000
Restore Ntc
B_temp1 = 0
B_temp2 = 0
While B_temp2 = 0
   Read Temp_i
   If Temp_i < Temperature Then B_temp2 = 1
   Incr B_temp1
   If B_temp1 > 100 Then B_temp2 = 1
Wend
Tx_b(1) = &H1C
Tx_b(2) = B_temp1 - 1
Tx_write_pointer = 3
Gosub Print_tx
Gosub Command_received
Return
'
FFFE:
      If Commandpointer >= 2 Then
         Select Case Command_b(2)
            Case 0
               If Commandpointer >= 3 Then
                  If Command_b(3) = 0 Then
                     Gosub Command_received
                  Else
                     B_temp1 = Command_b(3) + 3
                     If Commandpointer >= B_temp1 Then
                        Dev_name = String(20 , 0)
                        If B_temp1 > 23 Then B_temp1 = 23
                        For B_temp2 = 4 To B_temp1
                           Dev_name_b(B_temp2 - 3) = Command_b(B_temp2)
                        Next B_temp2
                        Dev_name_eeram = Dev_name
                     End If
                  End If
               End If
            Case 1
               If Commandpointer >= 3 Then
                  Dev_number = Command_b(3)
                  Dev_number_eeram = Dev_number
                  Gosub Command_received
               End If
            Case 2
               If Commandpointer >= 3 Then
                  B_temp2 = Command_b(3)
                  If B_temp2 < 2 Then
                     Serial_active = B_temp2
                     Serial_active_eeram = Serial_active
                  Else_Parameter_error
                  Gosub Command_received
               End If
'
                $include "__command254.bas"
'
            Case Else
               Parameter_error
               Gosub Command_received
         End Select
      End If
Return
'
FFFF:
      If Commandpointer >= 2 Then
         Tx_time = 1
         Tx_b(1) = &HFF
         Tx_b(2) = Command_b(2)
         Select Case Command_b(2)
            Tx_write_pointer = 0
            Case 0
               'Will send &HFF00 for empty string
               B_temp3 = Len(Dev_name)
               Tx_b(3) = B_temp3
               Tx_write_pointer = 4
               B_temp2 = 1
               While B_temp2 <= B_temp3
                  Tx_b(Tx_write_pointer) = Dev_name_b(B_temp2)
                  Incr Tx_write_pointer
                  Incr B_temp2
               Wend
            Case 1
               Tx_b(3) = Dev_number
               Tx_write_pointer = 4
            Case 2
               Tx_b(3) = Serial_active
               Tx_write_pointer = 4
            Case 3
               Tx_b(3) = 0
               Tx_write_pointer = 4
            Case 4
               Tx_b(3) = 3
               Tx_b(4) = "8"
               Tx_b(5) = "N"
               Tx_b(6) = "1"
               Tx_write_pointer = 7

'
            $include "__command255.bas"
'
            Case Else
               Parameter_error
         End Select
         If Tx_write_pointer > 0 Then
            Gosub Print_tx
         End If
         Gosub Command_received
      End If
Return