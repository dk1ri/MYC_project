' Commands
' 20200504
'
00:
   Tx_time = 1
   A_line = 0
   Number_of_lines = 1
   Send_line_gaps = 2
   Gosub Sub_restore
   Gosub Print_tx
   Gosub Command_received
Return
'
01:
      Gosub Read_data
      Tx_time = 1
      Tx_b(1) = &H01
      Tx_b(2) = Temperature_b(2)
      Tx_b(3) = Temperature_b(1)
      Tx_write_pointer = 4
      Gosub Print_tx
      Gosub Command_received
Return
'
02:
      Gosub Read_data
      Tx_time = 1
      Tx_b(1) = &H02
      Tx_b(2) = Humidity_b(3)
      Tx_b(3) = Humidity_b(2)
      Tx_b(4) = Humidity_b(1)
      Tx_write_pointer = 5
      Gosub Print_tx
      Gosub Command_received
Return
'
03:
      Gosub Read_data
      Tx_time = 1
      Tx_b(1) = &H03
      Tx_b(2) = Pressure_b(3)
      Tx_b(3) = Pressure_b(2)
      Tx_b(4) = Pressure_b(1)
      Tx_write_pointer = 5
      Gosub Print_tx
      Gosub Command_received
Return
'
04:
      If Commandpointer = 2 Then
         If Command_b(2) < 5 Then
            Reg_F2 = Command_b(2) + 1
            Reg_F2_eeram = Reg_F2
            Gosub Write_config
         Else
            Parameter_error
         End If
         Gosub Command_received
      End If
Return
'
05:
      Tx_time = 1
      Tx_b(1) = &H05
      Tx_b(2) = Reg_F2 - 1
      Tx_write_pointer = 3
      Gosub Print_tx
      Gosub Command_received
Return
'
06:
       If Commandpointer >= 2 Then
         If Command_b(2) < 5 Then
            Command_b(2) = Command_b(2) + 1
            Shift Command_b(2), Left, 2
            Reg_F4 = Reg_F4 And &B11100011
            Reg_F4 = Reg_F4 Or Command_b(2)
            Reg_F4_eeram = Reg_F4
            Gosub Write_config
         Else
            Parameter_error
         End If
         Gosub Command_received
      End If
Return
'
07:
      Tx_time = 1
      Tx_b(1) = &H07
      B_temp1 = Reg_F4
      B_temp1 = B_temp1 And &B00011100
      Shift B_temp1, Right, 2
      Tx_b(2) = B_temp1 - 1
      Tx_write_pointer = 3
      Gosub Print_tx
      Gosub Command_received
Return
'
08:
      If Commandpointer >= 2 Then
         If Command_b(2) < 5 Then
            Command_b(2) = Command_b(2) + 1
            Shift Command_b(2), Left, 5
            Reg_F4 = Reg_F4 And &B00011111
            Reg_F4 = Reg_F4 Or Command_b(2)
            Reg_F4_eeram = Reg_F4
            Gosub Write_config
         Else
            Parameter_error
         End If
         Gosub Command_received
      End If
Return
'
09:
      Tx_time = 1
      Tx_b(1) = &H09
      B_temp1 = Reg_F4
      B_temp1 = B_temp1 AND &B11100000
      Shift B_temp1, Right, 5
      Tx_b(2) = B_temp1 - 1
      Tx_write_pointer = 3
      Gosub Print_tx
      Gosub Command_received
Return
'
0A:
      If Commandpointer = 2 Then
         If Command_b(2) < 5 Then
            Shift Command_b(2), Left, 2
            Reg_F5 = Reg_F5 And &B11100011
            Reg_F5 = Reg_F5 OR Command_b(2)
            Reg_F5_eeram = Reg_F5
            Gosub Write_config
         Else
            Parameter_error
         End If
         Gosub Command_received
      End If
Return
'
0B:
      Tx_time = 1
      Tx_b(1) = &H0D
      B_temp1 = Reg_F5
      B_temp1 = B_temp1 And &B00011100
      Shift B_temp1, Right, 2
      Tx_b(2) = B_temp1
      Tx_write_pointer = 3
      Gosub Print_tx
      Gosub Command_received
Return
'
0C:
      B_temp1 = &HD0
      B_temp2 = 1
      Gosub Receive_i2c
      Tx_time = 1
      Tx_b(1) = &H0E
      Tx_b(2) = I2C_buffer_b(1)
      Tx_write_pointer = 3
      Gosub Print_tx
      Gosub Command_received
Return
'
0D:
      Stop Watchdog
      I2C_buffer_b(1) = &H60
      'E0 MSB reset for write -> 60
      I2C_buffer_b(2) = &HB6
      B_temp1 = 2
      Gosub Send_i2c
      Reg_F2_eeram = Reg_F2_default
      Reg_F4_eeram = Reg_F4_default
      Reg_F5_eeram = Reg_F5_default
      Reg_F2 = Reg_F2_eeram
      Reg_F4 = Reg_F4_eeram
      Reg_F5 = Reg_F5_eeram
      Gosub Write_config
      Gosub Read_correction
      Start Watchdog
      Gosub Command_received
Return
'
0E:
   If Interface_mode = 0 Then
      If Commandpointer >= 2 Then
         If Command_b(2) < 4 Then
            If Radio_type <> Command_b(2) Then
               Radio_type = Command_b(2)
               Radio_type_eram = Command_b(2)
               Goto Restart
            End If
         Else
            Parameter_error
         End If
         Gosub Command_received
      End If
   Else
      Not_valid_at_this_time
      Gosub Command_received
   End If
Return
'
0F:
   If Interface_mode = 0 Then
      Tx_time = 1
      Tx_b(1) = &H11
      Tx_b(2) = Radiotype
      Tx_write_pointer = 3
      Gosub Print_tx
      Gosub Command_received
   Else
      Not_valid_at_this_time
      Gosub Command_received
   End If
Return
'
10:
   If Interface_mode = 0 Then
      If Commandpointer >= 2 Then
         B_temp1 = Command_b(2) + 1
         If B_temp1 <= Name_len Then
            If Commandpointer >= B_temp1 Then
               B_temp2 = 1
               For B_temp1 = 3 To B_temp1
                  Radio_name_b(B_temp2) = Command_b(B_temp1)
                  Incr B_temp2
               Next B_temp1
               Radio_name_eram = Radio_name
               Gosub Command_received
            End If
         Else
            Parameter_error
            Gosub Command_received
         End If
      End If
   Else
      Not_valid_at_this_time
   End If
Return
'
11:
   If Interface_mode = 0 Then
      Tx_time = 1
      Tx_b(1) = &H13
      Tx_b(2) = len(Radio_name)
      B_temp2 = 3
      For B_temp1 = 1 to Tx_b(2)
          Tx_b(B_temp2) = Radio_name_b(B_temp1)
          Incr B_temp2
      Next B_temp1
      Tx_write_pointer = B_temp2
      Gosub Print_tx
      Gosub Command_received
   Else
      Not_valid_at_this_time
      Gosub Command_received
   End If
Return
'
12:
   If Interface_mode = 0 Then
      If Commandpointer >= 3 Then
         Radio_frequency = Command_b(2) * 256
         Radio_frequency = Radio_frequency + Command_b(3)
         If Radio_frequency < 612903 Then
            Radio_frequency = Radio_frequency + 137000000
            Radio_frequency = Radio_frequency * 62
            Radio_frequency_eeram = Radio_frequency
            Select Case Radio_type
               Case 0
                  Gosub Set_radio_f0
            End Select
         Else
            Parameter_error
         End If
      End If
   Else
      Not_valid_at_this_time
      Gosub Command_received
   End If
Return
'
13:
   If Interface_mode = 0 Then
      Tx_time = 1
      Tx_b(1) = &H15
      D_temp1 = Radio_frequency - 137000000
      D_temp1 = D_temp1 / 62
      Tx_b(2) = D_temp1_b(1)
      Tx_b(3) = D_temp1_b(2)
      Tx_write_pointer = 4
      Gosub Print_tx
      Gosub Command_received
   Else
      Not_valid_at_this_time
      Gosub Command_received
   End If
Return
'
14:
   If Interface_mode = 0 Then
      If Commandpointer >= 4 Then
         Radio_frequency = Command_b(2) * 256
         Radio_frequency = Radio_frequency + Command_b(3)
         If Radio_frequency < 1854838 Then
            Radio_frequency = Radio_frequency + 410000000
            Radio_frequency = Radio_frequency * 62
            Radio_frequency_eeram = Radio_frequency
            Select Case Radio_type
               Case 0
                  Gosub Set_radio_f0
            End Select
         Else
            Parameter_error
         End If
      End If
   Else
      Not_valid_at_this_time
      Gosub Command_received
   End If
Return
'
15:
   If Interface_mode = 0 Then
      Tx_time = 1
      Tx_b(1) = &H17
      D_temp1 = Radio_frequency - 410000000
      D_temp1 = D_temp1 / 62
      Tx_b(2) = D_temp1_b(1)
      Tx_b(3) = D_temp1_b(2)
      Tx_b(4) = D_temp1_b(3)
      Tx_write_pointer = 5
      Gosub Print_tx
      Gosub Command_received
   Else
      Not_valid_at_this_time
      Gosub Command_received
   End If
Return
'
16:
   If Interface_mode = 0 Then
       If Commandpointer >= 4 Then
          Radio_frequency = Command_b(2) * 256
          Radio_frequency = Radio_frequency + Command_b(3)
          If Radio_frequency < 1019999 Then
             Radio_frequency = Radio_frequency + 820000000
             Radio_frequency = Radio_frequency * 62
             Radio_frequency_eeram = Radio_frequency
             Select Case Radio_type
                Case 0
                   Gosub Set_radio_f0
             End Select
          Else
             Parameter_error
          End If
       End If
   Else
      Not_valid_at_this_time
      Gosub Command_received
   End If
Return
'
17:
   If Interface_mode = 0 Then
      Tx_time = 1
      Tx_b(1) = &H19
      D_temp1 = Radio_frequency - 820000000
      D_temp1 = D_temp1 / 62
      Tx_b(2) = D_temp1_b(1)
      Tx_b(3) = D_temp1_b(2)
      Tx_b(4) = D_temp1_b(3)
      Tx_write_pointer = 5
      Gosub Print_tx
      Gosub Command_received
   Else
      Not_valid_at_this_time
      Gosub Command_received
   End If
Return