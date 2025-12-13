' Commands
' 20250805
'
00:
   Gosub Print_basic
   Gosub Print_tx
   Gosub Command_received
Return
'
01:
   Old_commandpointer = Commandpointer
   I2c_data_b(1) = Shunt_voltage_reg
   Gosub Read_i2c_data
   Gosub Complement
    If Is_minus = 0 Then
       W_temp1 = W_temp1 + 32767
    Else
       W_temp1 = 32767 - W_temp1
    End If
    Tx_b(1) = &H01
    Tx_b(2) = W_temp1_h
    Tx_b(3) = W_temp1_l
    Tx_write_pointer = 4
    Gosub Print_tx
Return
'
02:
   Old_commandpointer = Commandpointer
   I2c_data_b(1) = Bus_voltage_reg
   Gosub Read_i2c_data
   W_temp1_h = I2c_data_b(1)
   W_temp1_l = I2c_data_b(2)
   'shift out the low bits !!!!
   shift W_temp1, right, 3
   W_temp1 = W_temp1 * 4
   Tx_b(1) = &H02
   Tx_b(2) = W_temp1_h
   Tx_b(3) = W_temp1_l
   Tx_write_pointer = 4
   Gosub Print_tx
Return
'
03:
   Old_commandpointer = Commandpointer
   I2c_data_b(1) = Current_reg
   Gosub Read_i2c_data
   Gosub Complement
   If Is_minus = 0 Then
      W_temp1 = W_temp1 + 32767
   Else
      W_temp1 = 32767 - W_temp1
   End If
   Tx_b(1) = &H03
   Tx_b(2) = W_temp1_h
   Tx_b(3) = W_temp1_l
   Tx_write_pointer = 4
   Gosub Print_tx

Return
'
04:
   Old_commandpointer = Commandpointer
   I2c_data_b(1) = Power_reg
   Gosub Read_i2c_data
   W_temp1_h = I2c_data_b(1)
   W_temp1_l = I2c_data_b(2)
   B_temp1 = W_temp1
   Tx_b(1) = &H04
   Tx_b(2) = B_temp1
   Tx_write_pointer = 3
   Gosub Print_tx
Return
'
05:
   Old_commandpointer = Commandpointer
   I2c_data_b(1) = Bus_voltage_reg
   Gosub Read_i2c_data
   W_temp1_h = I2c_data_b(1)
   W_temp1_l = I2c_data_b(2)
   shift W_temp1, right, 3
   W_temp1 = W_temp1
   ' V in mV
   Si_temp_w0 = W_temp1
   '
   I2c_data_b(1) = Current_reg
   Gosub Read_i2c_data
   Gosub Complement
' I in mA
   W_temp1 = W_temp1
   Si_temp_w0 = Si_temp_w0 * W_temp1
   Si_temp_w0 = Si_temp_w0 / 1000
   D_temp1 = Si_temp_w0
   ' P in mW
   Tx_b(1) = &H05
   ' 3 byte
   Tx_b(2) = D_temp1_b(3)
   Tx_b(3) = D_temp1_b(2)
   Tx_b(4) = D_temp1_b(1)
   Tx_write_pointer = 5
   Gosub Print_tx
Return
'
06:
   If Commandpointer >= 3 Then
      Old_commandpointer = Commandpointer
      I2c_data_b(1) = Calibration_reg
      I2c_data_b(2) = Command_b(2)
      I2c_data_b(3) = Command_b(3)
      B_temp1 = 3
      Gosub Write_i2c_data
      Gosub Command_received
   End If
Return
'
07:
   I2c_data_b(1) = Calibration_reg
   Gosub Read_i2c_data
   Tx_b(1) = &H07
   Tx_b(2) = I2c_data_b(1)
   Tx_b(3) = I2c_data_b(2)
   Tx_write_pointer = 4
   Gosub Print_tx
   Gosub Command_received
Return
'
08:
   If Commandpointer >= 3 Then
      Old_commandpointer = Commandpointer
      'never as wireless command
      If Command_origin <> 4 Then
         ' config Jumper required
         If Mode_in = 0 Then
            W_temp1 = Command_b(2) * 256
            W_temp1 = W_temp1 + Command_b(3)
            If W_temp1 < 1700 Then
               Radio_frequency0 = W_temp1
               Radio_frequency0_eeram = Radio_frequency0
               D_temp1 = Radio_frequency0 * 1000
               Gosub Set_frequency_0
            Else
               Not_valid_at_this_time
            End If
            Gosub Command_received
         Else
            Not_valid_at_this_time
         End If
      Else
         Not_valid_at_this_time
      End If
      Gosub Command_received
   End If
Return
'
09:
   Old_commandpointer = Commandpointer
   If Radio_type = 0 Then Gosub Read_frequency_0
   Tx_b(1) = &H09
   print Radio_frequency0
   w_temp1 = Radio_frequency0
   Tx_b(2) = w_temp1_h
   Tx_b(3) = w_temp1_l
   Tx_write_pointer = 4
   Gosub Print_tx
Return
'
10:
   If Commandpointer >= 2 Then
      Old_commandpointer = Commandpointer
      'never as wireless command
      If Command_origin <> 4 Then
         ' config Jumper required
         If Mode_in = 0 Then
            If Command_b(2) < 129 Then
               Radio_frequency4 = B_temp1
               Radio_frequency4_eeram = Radio_frequency4
               Gosub Set_frequency_nrf244
            Else
               Not_valid_at_this_time
            End If
         Else
            Not_valid_at_this_time
         End If
      Else
         Not_valid_at_this_time
      End If
      Gosub Command_received
   End If
Return
'
11:
   Old_commandpointer = Commandpointer
   If Radio_type = 4 Then Gosub Read_frequency_nrf244
   Tx_b(1) = &H0B
   Tx_b(2) = Radio_frequency4
   Tx_write_pointer = 3
   Gosub Print_tx
Return
'
12:
   Old_commandpointer = Commandpointer
   Tx_b(1) = &H0C
   If Mode_in = 0 Then
      Tx_b(2) = 1
   Else
      Tx_b(2) = 0
   End If
   Tx_write_pointer = 3
   Gosub Print_tx
Return