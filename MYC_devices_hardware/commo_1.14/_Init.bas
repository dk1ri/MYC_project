' init
' 20250820
'
   Dev_number = Dev_number_eeram
   Dev_name = Dev_name_eeram
   Command_no = 1
   Error_cmd_no = 0
   Send_line_gaps = 0
   Tx_pointer = 1
   Tx_write_pointer = 1
   Tx_time = 0
   Timeout_I = 0
   Timeout_J = 0
   '
   Gosub Command_received
   '
   Serial_active = Serial_active_eeram
   USB_active = USB_active_eeram
   I2c_active = I2c_active_eeram
   Radio_type = Radiotype_default
'
#If Use_i2c = 1
   Adress = Adress_eeram
   I2C_active = I2C_active_eeram
   Gosub Reset_i2c
#EndIf
'
#If Use_wireless = 1
   ' valid for interface always
   Radio_type = Radio_type_eeram
   Radio_name = Radio_name_eeram
   ' set frequency to default, when radi0_type is modifiered
'  If Radio_type <> Radio_type_old_eram Then
   Radio_frequency = Radio_frequency_eeram
'
   Rx_started = 1
   Spi_len = 0
   Send_wireless = 0
   Rx_bytes = 0
   Commandpointer_old = 0
   wireless_serial_rx_count = 0
   Spi_in = String(100,0)
   Wait_for_rx_ready = 0
   From_wireless = 0
   ' do this alway: If harsware not connected: no effect
   Gosub wireless_setup
#ENDIF
   Gosub Check_command_allowed
'

   $include  "__init.bas"
'