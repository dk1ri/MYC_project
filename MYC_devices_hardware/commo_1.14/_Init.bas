' init
' 20251206
'
   Dev_number = Dev_number_eeram
   Dev_name = Dev_name_eeram
   Command_no = 1
   Error_cmd_no = 0
   Cmd_error = 0
   Tx_write_pointer = 1
   Tx_pointer = 0
   Timeout_I = 0
   Timeout_J = 0
   '
   Gosub Command_received
   '
   Serial_active = Serial_active_eeram
   Baudrate = Baudrate_eeram
   Ser_mode = Ser_mode_eeram
   USB_active = USB_active_eeram
   I2c_active = I2c_active_eeram
   Radio_active = Radio_active_eeram
   Radio_type = Radio_type_eeram
   Radio_name = Radio_name_eeram
'
#If Use_i2c = 1
   Adress = Adress_eeram
   I2C_active = I2C_active_eeram
   Gosub Reset_i2c
#EndIf
'
#If Use_wireless = 1
   ' set frequency to default, when radi0_type is modifiered
   Radio_frequency0 = Radio_frequency0_eeram
   Radio_frequency4 = Radio_frequency4_eeram
'
   Spi_len = 0
   Spi_IO = String(100,0)
   ' do this alway: If harsware not connected: no effect
   Gosub wireless_setup
#ENDIF
'
   $include  "__init.bas"
'