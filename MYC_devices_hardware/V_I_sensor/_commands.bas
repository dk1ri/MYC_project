' Commands
' 20241221
'
00:
   Tx_time = 1
   Gosub Sub_restore
   If Command_mode = 1 Then Gosub Print_tx
   Gosub Command_received
Return
'
01:
   Ina_register = Shunt_voltage_reg
   Offset = 32000
    Gosub Read_i2c_data
   Gosub Complement
   If Is_minus = 0 Then
      I2c_rx_data = I2c_rx_data + Offset
   End If
   Is_minus = 0
   Tx_b(1) = &H01
   Tx_b(2) = High(I2c_rx_data)
   Tx_b(3) = Low(I2c_rx_data)
   Tx_write_pointer = 4
   Gosub Print_to_all
   Gosub Command_received
Return
'
02:
   Ina_register = Bus_voltage_reg
   Gosub Read_i2c_data
   Shift I2c_rx_data, Right, 3
   ' max 8000 -> 32000
   Shift I2c_rx_data, Left, 2
   Tx_b(1) = &H02
   Tx_b(2) = High(I2c_rx_data)
   Tx_b(3) = Low(I2c_rx_data)
   Tx_write_pointer = 4
   Gosub Print_to_all
   Gosub Command_received
Return
'
03:
   Ina_register = Current_reg
   Offset = 16000
    Gosub Read_i2c_data
   Gosub Complement
   If Is_minus = 0 Then
      I2c_rx_data = I2c_rx_data + Offset
   End If
   Is_minus = 0
   Tx_b(1) = &H03
   Tx_b(2) = High(I2c_rx_data)
   Tx_b(3) = Low(I2c_rx_data)
   Tx_write_pointer = 4
   Gosub Print_to_all
   Gosub Command_received
Return
'
04:
   Ina_register = Power_reg
   Tx_b(1) = &H04
   Tx_b(2) = High(I2c_rx_data)
   Tx_b(3) = Low(I2c_rx_data)
   Tx_write_pointer = 4
   Gosub Print_to_all
   Gosub Command_received
Return
'
05:
   If Commandpointer >= 3 Then
      Ina_register = Calibration_reg
      I2c_tx_data_b(1)  = Ina_register
     I2c_tx_data_b(2) = Command_b(2)
     I2c_tx_data_b(3) = Command_b(3)
     Gosub Write_i2c_data
     Gosub Command_received
   End If
Return
'
06:
   Ina_register = Calibration_reg
   Tx_b(1) = &H06
   Tx_b(2) = High(I2c_rx_data)
   Tx_b(3) = Low(I2c_rx_data)
   Tx_write_pointer = 4
   Gosub Print_to_all
   Gosub Command_received
Return
'