' Commands
' 20241221
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
   Ina_register = Shunt_voltage_reg
   Gosub Read_i2c_data
 '  printbin I2c_rx_data_b(1)
   Gosub Complement
   If W_temp1 <= 30000 Then
  ' print Is_minus
 '  printbin w_temp1
      If Is_minus = 0 Then
         W_temp1 = W_temp1 + 30000
      Else
         W_temp1 = 30000 - W_temp1
      End If
      Tx_b(1) = &H01
      Tx_b(2) = W_temp1_h
      Tx_b(3) = W_temp1_l
      Tx_write_pointer = 4
      Gosub Print_tx
   Else
      High_value
   End If
   Gosub Command_received
Return
'
02:
   Ina_register = Bus_voltage_reg
   Gosub Read_i2c_data
   W_temp1_h = I2c_rx_data_b(1)
   W_temp1_l = I2c_rx_data_b(2)
   'shift out the low bits !!!!
   shift W_temp1, right, 3
   W_temp1 = W_temp1 * 4
   Tx_b(1) = &H02
   Tx_b(2) = W_temp1_h
   Tx_b(3) = W_temp1_l
   Tx_write_pointer = 4
   Gosub Print_tx
   Gosub Command_received
Return
'
03:
   Ina_register = Current_reg
   Gosub Read_i2c_data
   Gosub Complement
   If W_temp1 <= 30000 Then
      If Is_minus = 0 Then
         W_temp1 = W_temp1 + 30000
      Else
         W_temp1 = 30000 - W_temp1
      End If
      Tx_b(1) = &H03
      Tx_b(2) = W_temp1_h
      Tx_b(3) = W_temp1_l
      Tx_write_pointer = 4
      Gosub Print_tx
   Else
      High_value
   End If
   Gosub Command_received
Return
'
04:
   Ina_register = Power_reg
   Gosub Read_i2c_data
   W_temp1_h = I2c_rx_data_b(1)
   W_temp1_l = I2c_rx_data_b(2)
   W_temp1 = W_temp1 * 2
   If W_temp1 <= 30000 Then
      Tx_b(1) = &H04
      Tx_b(2) = W_temp1_h
      Tx_b(3) = W_temp1_l
      Tx_write_pointer = 4
      Gosub Print_tx
   End If
   Gosub Command_received
Return
'
05:
   Ina_register = Bus_voltage_reg
   Gosub Read_i2c_data
   W_temp1_h = I2c_rx_data_b(1)
   W_temp1_l = I2c_rx_data_b(2)
   shift W_temp1, right, 3
   W_temp1 = W_temp1 * 4
   S = W_temp1
   '
   Ina_register = Shunt_voltage_reg
   Gosub Read_i2c_data
   Gosub Complement
   If W_temp1 <= 30000 Then
      S = S * W_temp1
      ' U / 0.1 Ohm
      ' S = S * 10
      ' result in 10nW -> / 1000 -> in 10uW
      S = S / 100
      D_temp1 = S
      Tx_b(1) = &H05
      ' 3 byte
      Tx_b(2) = D_temp1_b(3)
      Tx_b(3) = D_temp1_b(2)
      Tx_b(4) = D_temp1_b(1)
      Tx_write_pointer = 5
      Gosub Print_tx
   Else
      High_value
   End If
Return
'
06:
   If Commandpointer >= 3 Then
      Ina_register = Calibration_reg
      I2c_tx_data_b(1) = Ina_register
      I2c_tx_data_b(2) = Command_b(2)
      I2c_tx_data_b(3) = Command_b(3)
      Gosub Write_i2c_data
      Gosub Command_received
   End If
Return
'
07:
   Ina_register = Calibration_reg
   Gosub Read_i2c_data
   Tx_b(1) = &H07
   Tx_b(2) = I2c_rx_data_b(1)
   Tx_b(3) = I2c_rx_data_b(2)
   Tx_write_pointer = 4
   Gosub Print_tx
   Gosub Command_received
Return
'
08:
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
09:
   If Interface_mode = 0 Then
      Tx_time = 1
      Tx_b(1) = &H09
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
      Tx_b(1) = &H0B
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
      Tx_b(1) = &H0D
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
      Tx_b(1) = &H0F
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
      Tx_b(1) = &H011
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
'
18:
   Tx_time = 1
   Tx_b(1) = &H12
   Tx_b(2) = Interface_mode
   Tx_write_pointer = 3
   Gosub Print_tx
   Gosub Command_received
Return
'